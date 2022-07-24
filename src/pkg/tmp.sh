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

# create temporary folders/files for pkg::download()
pkg::tmp::download() {
	log::debug "starting ${FUNCNAME}()"
	pkg::tmp::remove
	log::debug "creating tmp package files/folders"

	# general package folders
	declare -Ag TMP_PKG

	TMP_PKG[${PKG[short]}_main]="$(mktemp -d /tmp/monero-bash.XXXXXXXXXX)"
	TMP_PKG[${PKG[short]}_pkg]="$(mktemp -d ${TMP_PKG[${PKG[short]}_main]}/monero-bash-pkg.XXXXXXXXXX)"
	TMP_PKG[${PKG[short]}_gpg]="$(mktemp ${TMP_PKG[${PKG[short]}_main]}/monero-bash-gpg.XXXXXXXXXX)"
	TMP_PKG[${PKG[short]}_sig]="$(mktemp ${TMP_PKG[${PKG[short]}_main]}/monero-bash-sig.XXXXXXXXXX)"
	TMP_PKG[${PKG[short]}_hash]="$(mktemp ${TMP_PKG[${PKG[short]}_main]}/monero-bash-hash.XXXXXXXXXX)"

	# log::debug
	log::debug "--- tmp pkg folders ---"
	log::debug "TMP_PKG[main] | ${TMP_PKG[main]}"
	log::debug "TMP_PKG[pkg]  | ${TMP_PKG[pkg]}"
	log::debug "TMP_PKG[gpg]  | ${TMP_PKG[gpg]}"
	log::debug "TMP_PKG[sig]  | ${TMP_PKG[sig]}"
	log::debug "TMP_PKG[hash] | ${TMP_PKG[hash]}"
}

# create temporary files for pkg::update() and pkg::info()
# assigning variables in the background &
# is almost impossible without eval, so
# temporary ram files are used in place of
# direct variables containing info.
#
# usage: $1 = [update|info]
# changes behavior on folder creation
pkg::tmp::info() {
	log::debug "starting ${FUNCNAME}()"
	pkg::tmp::remove
	log::debug "creating tmp package info files"

	map TMP_INFO TMP_INFO[main] TMP_INFO[bash] TMP_INFO[monero] TMP_INFO[p2pool] TMP_INFO[xmrig]

	if [[ $1 = update ]]; then
		TMP_INFO[main]="$(mktemp -d /tmp/monero-bash-info.XXXXXXXXXX)"
		TMP_INFO[bash]="$(mktemp ${TMP_INFO[main]}/bash-info.XXXXXXXXXX)"
		[[ $MONERO_VER ]] && TMP_INFO[monero]="$(mktemp ${TMP_INFO[monero]}/monero-info.XXXXXXXXXX)"
		[[ $P2POOL_VER ]] && TMP_INFO[p2pool]="$(mktemp ${TMP_INFO[p2pool]}/p2pool-info.XXXXXXXXXX)"
		[[ $XMRIG_VER ]]  && TMP_INFO[xmrig]="$(mktemp ${TMP_INFO[xmrig]}/xmrig-info.XXXXXXXXXX)"
	elif [[ $1 = info ]]; then
		TMP_INFO[main]="$(mktemp -d /tmp/monero-bash-info.XXXXXXXXXX)"
		[[ $MONERO_BASH_OLD = true ]] && TMP_INFO[bash]="$(mktemp ${TMP_INFO[main]}/bash-info.XXXXXXXXXX)"
		[[ $MONERO_OLD = true ]]      && TMP_INFO[monero]="$(mktemp ${TMP_INFO[monero]}/monero-info.XXXXXXXXXX)"
		[[ $P2POOL_OLD = true ]]      && TMP_INFO[p2pool]="$(mktemp ${TMP_INFO[p2pool]}/p2pool-info.XXXXXXXXXX)"
		[[ $XMRIG_OLD = true ]]       && TMP_INFO[xmrig]="$(mktemp ${TMP_INFO[xmrig]}/xmrig-info.XXXXXXXXXX)"
	fi

	# log::debug
	log::debug "--- tmp info folders ---"
	log::debug "TMP_INFO[main]   | ${TMP_INFO[main]}"
	log::debug "TMP_INFO[bash]   | ${TMP_INFO[bash]}"
	log::debug "TMP_INFO[monero] | ${TMP_INFO[monero]}"
	log::debug "TMP_INFO[p2pool] | ${TMP_INFO[p2pool]}"
	log::debug "TMP_INFO[xmrig]  | ${TMP_INFO[xmrig]}"
	return 0
}

# remove monero-bash temp files
pkg::tmp::remove() {
	log::debug "starting ${FUNCNAME}()"
	if find /tmp/monero-bash* &>/dev/null; then
		log::debug "old tmp folders found, removing"
		rm -rf /tmp/monero-bash*
	else
		log::debug "no old tmp folders found, skipping"
	fi
}
