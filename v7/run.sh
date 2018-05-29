#!/bin/bash
MYSQL='mysql --user=snapcar --password=oycobe --host=data.appcar.com.ar --port=23849'
#MYSQL='mysql --host=127.0.0.1 --port=3307 --user=snapcar --password=snapcar'

while [ "$1" ] ; do
	echo Procesando ... $1
	$MYSQL --database=score < "$1"
	shift
done
