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

#sccache 
export RUSTC_WRAPPER="/usr/bin/sccache"
export SCCACHE_DIR="/var/cache/sccache"
export SCCACHE_MAX_FRAME_LENGTH="104857600"
#sccache

#gentoo-binhost

if [[ ${EBUILD_PHASE} == 'postinst' ]]; then
  # FIXME come up with a more sophisticated approach to detect if binary package build is actually requested
  # commandline args like -B or --buildpkg-exclude and other conditionals are not supported right now.
  grep -q 'buildpkg' <<< {$PORTAGE_FEATURES}
  if [ $? -eq 0 ]; then
    /etc/portage/binhost/gh-upload.py
  fi
fi