# This file is part of monero-bash - a wrapper for Monero, written in Bash
#
# Copyright (c) 2022 hinto.janaiyo <https://github.com/hinto-janaiyo>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# Fetch and filter download links for package upgrades
# uses functions from pkg::update()
pkg::info() {
	log::debug "starting ${FUNCNAME}()"

	# VARIABLE AND TMP
	pkg::tmp::info info
	map VER HTML LINK_DOWN LINK_HASH LINK_SIG
	local UPDATE_FOUND
	declare -a SCRATCH

	# MULTI-THREAD PKG METADATA DOWNLOAD
	if [[ $MONERO_BASH_OLD = true ]]; then
		struct::pkg bash
		pkg::update::multi &
	fi
	if [[ $MONERO_OLD = true ]]; then
		struct::pkg monero
		pkg::update::multi &
	fi
	if [[ $P2POOL_OLD = true ]]; then
		struct::pkg p2pool
		pkg::update::multi &
	fi
	if [[ $XMRIG_OLD = true ]]; then
		struct::pkg xmrig
		pkg::update::multi &
	fi

	# WAIT FOR THREADS
	log::debug "waiting for metadata threads to complete"
	if ! wait -n; then
		print::exit "Update failure - unable to connect to GitHub"
	fi

	# FILTER VERSION VARIABLE $VER[${PKG[short]}}
	if [[ $MONERO_BASH_OLD = true ]]; then
		struct::pkg bash
		pkg::update::ver
		pkg::info::down
		pkg::info::hash
	fi
	if [[ $MONERO_OLD = true ]]; then
		struct::pkg monero
		pkg::update::ver
		pkg::info::down
		pkg::info::hash
	fi
	if [[ $P2POOL_OLD = true ]]; then
		struct::pkg p2pool
		pkg::update::ver
		pkg::info::down
		pkg::info::hash
	fi
	if [[ $XMRIG_OLD = true ]]; then
		struct::pkg xmrig
		pkg::update::ver
		pkg::info::down
		pkg::info::hash
		pkg::info::sig
	fi
}

# filter for the package download link
pkg::info::down() {
	log::debug "starting ${FUNCNAME}()"

	# use static link for [Monero]
	if [[ ${PKG[name]} = monero ]]; then
		LINK_DOWN="https://downloads.getmonero.org/cli/linux64"
		log::debug "package Monero detected, LINK_DOWN: $LINK_DOWN"
		return 0
	fi

	# filter output of other packages
	if [[ ${HTML[${PKG[short]}} = true ]]; then
		LINK_DOWN[${PKG[short]}]="$(grep -o "/${PKG[author]}/${PKG[name]}/releases/download/.*/${PKG[regex]}" "${TMP_INFO[${PKG[short]}]}")"
		LINK_DOWN[${PKG[short]}]="${LINK_DOWN[${PKG[short]}]//\"*}"
		LINK_DOWN[${PKG[short]}]="https://github.com/${LINK_DOWN[${PKG[short]}]}"
	else
		LINK_DOWN[${PKG[short]}]="$(grep -o "https://github.com/${PKG[author]}/${PKG[name]}/releases/download/.*/${PKG[regex]}" "${TMP_INFO[${PKG[short]}]}")"
		LINK_DOWN[${PKG[short]}]="${LINK_DOWN[${PKG[short]}]//\"}"
	fi
	log::debug "${PKG[name]} download link found: $LINK_DOWN"
}

# create the hash link out of existing variables
pkg::info::hash() {
	log::debug "starting ${FUNCNAME}()"

	# use static link for [Monero]
	if [[ ${PKG[name]} = monero ]]; then
		LINK_HASH="https://downloads.getmonero.org/cli/linux64"
		log::debug "package Monero detected, LINK_HASH: $LINK_HASH"
		return 0
	fi

	LINK_HASH="https://github.com/${PKG[author]}/${PKG[name]}/releases/download/${VER[${PKG[short]}]}/${PKG[hash]}"
	log::debug "${PKG[name]} hash link: $LINK_HASH"
}

# create the sig link out of existing variables
# only used for XMRig, everyone else has the
# signature within the hash file.
pkg::info::sig() {
	log::debug "starting ${FUNCNAME}()"

	LINK_SIG="https://github.com/${PKG[author]}/${PKG[name]}/releases/download/${VER[${PKG[short]}]}/${PKG[sig]}"
	log::debug "${PKG[name]} sig link: $LINK_SIG"
}
