#!/bin/bash

DIR=`dirname $0`
app=$DIR/main.js
name=main
LOG_DIR=$DIR/logs

if [ ! -d $LOG_DIR ];then
	mkdir $LOG_DIR
fi

start() {
	pm2 start -o $LOG_DIR/main.log -e $LOG_DIR/err.log $app --name "$name"
	return 0
}

stop() {
	pm2 stop $name
	return 0
}

status() {
	pm2 show $name
	return 0
}

# See how we were called.
case "$1" in
  start)
	start
	;;
  stop)
	stop
	;;
  restart|force-reload)
	stop
	start
	;;
  status)
	status
	;;
  reload)
	exit 3
	;;
  *)
	echo $"Usage: $0 {start|stop|status|restart}"
	exit 2
esac

