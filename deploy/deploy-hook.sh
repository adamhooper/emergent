#!/bin/sh
# This script will run _on each server_ during deploy.
#
# The CWD is the root of the project.
#
# We want zero downtime for our website. Here are the requirements:
#
# * If something breaks, our servers stay up
# * Iff everything succeeds, we return exit code 0

API_PORT_START="150" # 1500, 1501
EDITOR_PORT_START="160" # 1600, 1601

SS=/usr/sbin/ss

set -x
set -e

CWD="$(pwd)"

forever_cmd() {
  echo "/usr/local/bin/node /home/app/node_modules/forever/bin/forever -a -l /home/app/var/log/$1.log start --minUptime 1000 --spinSleepTime 1000 $CWD/bin/$1.js"
}

# Returns an open port number as a string.
#
# For rolling deploys, we'll deploy on either port "1500" or "1501" --
# whichever one is open. (The other one, we assume, is a running server.)
#
# Assumptions
# * ss is installed
# * grep is installed
# * the final digit of the port is always "0" or "1"
# * the server is always run by the current user
#
# $1: the first digits of the port number. For instance, "150" if we alternate
#     between ports "1500" and "1501".
find_open_port_starting_with() {
  port0="${1}0"
  port1="${1}1"
  if $($SS -plnt | grep ":$port0" > /dev/null); then
    echo $port1
  else
    echo $port0
  fi
}

# Returns a space-separated list of PIDs running on interesting ports.
#
# For rolling deploys, existing servers will be running on either port "1500"
# or "1501" -- or neither. We'll concatenate all the servers.
#
# Assumptions
# * ss is installed
# * grep is installed
# * the final digit of the port is always "0" or "1"
# * the server is always run by the current user
# * the server's master process is a direct child of init (PID 1)
# * we're on Linux, with /proc mounted properly
#
# $1: the first digits of the port number. For instance, "150" if we alternate
#     between ports "1500" and "1501".
find_forever_uids_for_port_starting_with() {
  # ss output might look like:
  # LISTEN     0      128                       *:1500                     *:*      users:(("node",1709,10))
  # LISTEN     0      128                       *:1501                     *:*      users:(("node",1691,10))
  node_pids="$($SS -plnt | grep ":${1}[01]" | sed -e 's/.*:((.*",\(.*\),.*/\1/')"
  for node_pid in $node_pids; do
    # forever list output might look like:
    # info:    Forever processes running
    # data:        uid  command             script                            forever pid   logfile                              uptime         
    # data:    [0] 0JUH /usr/local/bin/node /home/app/code/bin/editor.js      1657    1659  /home/app/var/log/editor.js.log      4:11:2:35.892  
    # data:    [1] n1at /usr/local/bin/node /home/app/code/bin/frontend.js    1672    1676  /home/app/var/log/frontend.js.log    4:11:2:33.679  
    # data:    [2] YJZU /usr/local/bin/node /home/app/code/bin/api.js         1689    1693  /home/app/var/log/api.js.log         4:11:2:30.459  
    # data:    [3] _1Zc /usr/local/bin/node /home/app/code/bin/url-fetcher.js 1703    28088 /home/app/var/log/url-fetcher.js.log 2:15:31:41.890 

    parent_pid=$(cat /proc/$node_pid/stat | cut -d' ' -f5)
    forever_uid=$(forever list --plain | sed -e 's/  */ /g' | cut -d' ' -f3,6 | grep " $parent_pid" | cut -d' ' -f1)
    echo $forever_uid
  done
}

# Finds the PIDs of the given command, using ps and grep
#
# Assumptions:
# * The process shows up in `ps x` as $1
# * The process is owned by the current user
# * The process doesn't include the string " pts/" anywhere
#
# $1: the command used to start the program
find_running_pids_for_command() {
  # Grep output looks like:
  #  1703 ?        Ssl    0:23 /usr/local/bin/node /home/app/node_modules/forever/bin/monitor /home/app/code/bin/url-fetcher.js
  # 28426 pts/0    R+     0:00 grep url-fetcher
  echo $(ps x | grep "$1" | grep -v ' pts/' | sed -e 's/\s*\([0-9]*\).*/\1/')
}

# Rolls over the given service
#
# $1: port number, minus the last digit
# $2: command to create a new instance
#
# The command will be run with NODE_ENV=production and PORT=$new_port.
#
# Assumptions (aside from those in other functions):
# * env is installed
rolling_restart() {
  port_start="$1"
  cmdline="$2"

  old_uids=$(find_forever_uids_for_port_starting_with $port_start)
  echo "Rolling over alongside server UID: $old_uids"

  new_port=$(find_open_port_starting_with $port_start)
  cmd="env NODE_ENV=production PORT=$new_port $cmdline"

  echo "Starting command that should daemonize: $cmd ..."
  $cmd

  server="http://localhost:$new_port"
  echo "Waiting for server to come online at $server ..."
  until $(curl --silent -o /dev/null "$server"); do
    echo "will try again"
    sleep 1
  done

  echo "Sleeping, so nginx notices our new server is online..."
  sleep 5

  for old_uid in $old_uids; do
    echo "Killing old server $old_uid ..."
    forever stop $old_uid
  done
}

restart_api() {
  rolling_restart "$API_PORT_START" "$(forever_cmd api)"
}

restart_editor() {
  rolling_restart "$EDITOR_PORT_START" "$(forever_cmd editor)"
}

restart_url_fetcher() {
  for url_fetcher_pid in $(find_running_pids_for_command url-fetcher.js); do
    echo "Killing url-fetcher with PID $url_fetcher_pid ..."
    kill $url_fetcher_pid
    echo "Waiting for PID $url_fetcher_pid to disappear..."
    while $(ps $url_fetcher_pid > /dev/null); do
      echo "..."
      sleep 1
    done
  done

  cmd=$(forever_cmd url-fetcher)
  echo "Starting command that should daemonize: $cmd ..."
  $($cmd)
}

(bin/npm-install-components.sh)
(cd "$CWD/data-store" && env NODE_ENV=production bin/sequelize db:migrate)
restart_api
restart_editor
