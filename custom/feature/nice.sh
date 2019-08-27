#!/usr/bin/env bash

set -e

if [ -z $1 ]; then
	>&2 echo "Usage: $0 PID"
	exit 1
fi

ionice -c 3 -p $1
chrt --verbose --idle -p 0 $1
