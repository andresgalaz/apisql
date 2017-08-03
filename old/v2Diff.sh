#!/bin/bash
ls *.* | awk '{print "diff "$1" v2/??_"$1}' | sh -vx 2>&1 | less
