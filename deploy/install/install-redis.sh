#!/bin/bash

set -e
set -x

mkdir /tmp/install-redis

pushd /tmp/install-redis

wget http://download.redis.io/releases/redis-2.8.9.tar.gz
tar zxf redis-2.8.9.tar.gz
pushd redis-2.8.9

make

sudo mkdir /etc/redis /var/lib/redis
sudo cp src/redis-server src/redis-cli /usr/local/bin

popd # redis-2.8.9
popd # /tmp/install-redis

rm -r /tmp/install-redis

cat <<-EOT | sudo tee /etc/redis/redis.conf
	daemonize yes
	bind 127.0.0.1
	dir /var/lib/redis
	pidfile /var/run/redis.pid
	port 6379

	loglevel notice
	logfile /var/log/redis.log

	tcp-backlog 511
	timeout 0
	databases 5
	save 900 1
	save 300 10
	save 60 10000
	dbfilename dump.rdb
	slowlog-log-slower-than 10000
	slowlog-max-len 128
	notify-keyspace-events KEA
	hash-max-ziplist-entries 512
	hash-max-ziplist-value 64
	list-max-ziplist-entries 512
	list-max-ziplist-value 64
	set-max-intset-entries 512
	zset-max-ziplist-entries 128
	zset-max-ziplist-value 64
	hll-sparse-max-bytes 3000
EOT

cat <<-'EOT' | sudo tee /etc/init.d/redis-server
	#!/bin/sh
	# From - http://www.codingsteps.com/install-redis-2-6-on-amazon-ec2-linux-ami-or-centos/
	# 
	# redis - this script starts and stops the redis-server daemon
	# Originally from - https://raw.github.com/gist/257849/9f1e627e0b7dbe68882fa2b7bdb1b2b263522004/redis-server
	#
	# chkconfig:   - 85 15 
	# description:  Redis is a persistent key-value database
	# processname: redis-server
	# config:      /etc/redis/redis.conf
	# config:      /etc/sysconfig/redis
	# pidfile:     /var/run/redis.pid

	# Source function library.
	. /etc/rc.d/init.d/functions

	# Source networking configuration.
	. /etc/sysconfig/network

	# Check that networking is up.
	[ "$NETWORKING" = "no" ] && exit 0

	redis="/usr/local/bin/redis-server"
	prog=$(basename $redis)

	REDIS_CONF_FILE="/etc/redis/redis.conf"

	[ -f /etc/sysconfig/redis ] && . /etc/sysconfig/redis

	lockfile=/var/lock/subsys/redis

	start() {
	    [ -x $redis ] || exit 5
	    [ -f $REDIS_CONF_FILE ] || exit 6
	    echo -n $"Starting $prog: "
	    daemon $redis $REDIS_CONF_FILE
	    retval=$?
	    echo
	    [ $retval -eq 0 ] && touch $lockfile
	    return $retval
	}

	stop() {
	    echo -n $"Stopping $prog: "
	    killproc $prog -QUIT
	    retval=$?
	    echo
	    [ $retval -eq 0 ] && rm -f $lockfile
	    return $retval
	}

	restart() {
	    stop
	    start
	}

	reload() {
	    echo -n $"Reloading $prog: "
	    killproc $redis -HUP
	    RETVAL=$?
	    echo
	}

	force_reload() {
	    restart
	}

	rh_status() {
	    status $prog
	}

	rh_status_q() {
	    rh_status >/dev/null 2>&1
	}

	case "$1" in
	    start)
	        rh_status_q && exit 0
	        $1
	        ;;
	    stop)
	        rh_status_q || exit 0
	        $1
	        ;;
	    restart|configtest)
	        $1
	        ;;
	    reload)
	        rh_status_q || exit 7
	        $1
	        ;;
	    force-reload)
	        force_reload
	        ;;
	    status)
	        rh_status
	        ;;
	    condrestart|try-restart)
	        rh_status_q || exit 0
	        ;;
	    *)
	        echo $"Usage: $0 {start|stop|status|restart|condrestart|try-restart|reload|force-reload}"
	        exit 2
	esac
EOT
sudo chmod +x /etc/init.d/redis-server

sudo chkconfig --add redis-server
sudo chkconfig --level 345 redis-server on

sudo service redis-server start

