#!/bin/bash
# (C) Martin V\"ath <martin at mvath.de>
# SPDX-License-Identifier: GPL-2.0-only
[ "`type -t BashrcdMain`" = function ] || \
. "${PORTAGE_CONFIGROOT%/}/etc/portage/bashrc.d/bashrcd.sh"
BashrcdMain "$@"

# This hook is neccesary for automatic updating of the cfg-update index, please do not modify it!
pre_pkg_setup() {
	[[ $ROOT = / ]] && cfg-update --index
}
