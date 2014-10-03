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
API_COMMAND="/usr/local/bin/node /home/app/node_modules/forever/bin/monitor bin/api.js"
EDITOR_COMMAND="/usr/local/bin/node /home/app/node_modules/forever/bin/monitor bin/editor.js"
URL_FETCHER_COMMAND="/usr/local/bin/node /home/app/node_modules/forever/bin/monitor bin/url-fetcher.js"

set -x

DIR="$(dirname "$0")"

(cd "$DIR/.." && bin/npm-install-components.sh)
(cd "$DIR/../data-store" && env NODE_ENV=production bin/sequelize db:migrate)

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
  if $(ss -plnt | grep ":$port0" > /dev/null); then
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
# * the server is always run in its own process session
# * we're on Linux, with /proc mounted properly
#
# $1: the first digits of the port number. For instance, "150" if we alternate
#     between ports "1500" and "1501".
find_running_pids_for_port_starting_with() {
  # ss output might look like:
  # LISTEN     0      128                       *:1500                     *:*      users:(("node",1709,10))
  # LISTEN     0      128                       *:1501                     *:*      users:(("node",1691,10))
  node_pids="$(ss -plnt | grep ":${1}[01]" | sed -e 's/.*:((.*",\(.*\),.*/\1/')"
  for node_pid in $node_pids; do
    echo $(cat /proc/$node_pid/stat | cut -d' ' -f6)
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

  old_pids=$(echo find_running_pids_for_port_starting_with($port_start))
  echo "Rolling over alongside server PID: $old_pids"

  new_port=$(echo find_open_port_starting_with($port_start))
  cmd="env - NODE_ENV=production PORT=$new_port $cmdline"

  echo "Starting command that should daemonize: $cmd ..."
  $(cmd)

  server="http://localhost:$new_port"
  echo "Waiting for server to come online at $server ..."
  until $(curl --silent -o /dev/null "$server"); do
    echo "will try again"
    sleep 1
  done

  for old_pid in $old_pids; do
    echo "killing old server $old_pid ..."
    kill $old_pid
  done

  echo "It'll die eventually. We're done here."
}

restart_api() {
  rolling_restart("$API_PORT_START", "$API_COMMAND")
}

restart_editor() {
  rolling_restart("$EDITOR_PORT_START", "$EDITOR_COMMAND")
}

restart_url_fetcher() {
  for url_fetcher_pid in $(find_running_pids_for_command("$URL_FETCHER_COMMAND")); do
    echo "Killing url-fetcher with PID $url_fetcher_pid ..."
    kill $url_fetcher_pid
    echo "Waiting for PID $url_fetcher_pid to disappear..."
    while $(ps $url_fetcher_pid > /dev/null); do
      echo "..."
      sleep 1
    done
  done

  echo "Starting command that should daemonize: $URL_FETCHER_COMMAND ..."
  $(URL_FETCHER_COMMAND)
}

bin/install-npm-components.sh
restart_api()
