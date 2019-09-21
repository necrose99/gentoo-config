#!/usr/bin/env bash

set -e

NAME=${0##*/}

function show_usage() {
	cat << EOF
Set minimum execution priority:

Usage: ${NAME} -p PID
Usage: ${NAME} COMMAND [ARG...]
EOF
}

while getopts "p:h" opt; do
	case $opt in
	p)
		PID=${OPTARG};;
	h)
		show_usage
		exit 0;;
	?)
		show_usage
		exit 1;;
	esac
done

PID=${PID:-$$}

chrt --idle -p 0 "${PID}"
ionice -c 3 -p "${PID}"
renice -n 19 -p "${PID}" > /dev/null

shift $(($OPTIND - 1))
((${#} == 0)) && exit 0

exec ${@}
