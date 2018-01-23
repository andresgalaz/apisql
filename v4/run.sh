#!/bin/bash
while [ "$1" ] ; do
	echo Procesando ... $1
	mysql --host=127.0.0.1 --port=3307 --user=snapcar --password=snapcar --database=score < "$1"
	shift
done
