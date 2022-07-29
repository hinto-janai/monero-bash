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
	log::debug "starting: ${PKG[pretty]}"

	# general package folders
	declare -Ag TMP_PKG

	TMP_PKG[${PKG[short]}_main]="$(mktemp -d /tmp/monero-bash-${PKG[short]}.XXXXXXXXXX)"
	TMP_PKG[${PKG[short]}_pkg]="$(mktemp -d ${TMP_PKG[${PKG[short]}_main]}/pkg.XXX)"
	TMP_PKG[${PKG[short]}_gpg]="$(mktemp ${TMP_PKG[${PKG[short]}_main]}/gpg.XXX)"
	TMP_PKG[${PKG[short]}_sig]="$(mktemp ${TMP_PKG[${PKG[short]}_main]}/sig.XXX)"
	TMP_PKG[${PKG[short]}_hash]="$(mktemp ${TMP_PKG[${PKG[short]}_main]}/hash.XXX)"
	TMP_PKG[${PKG[short]}_changes]="$(mktemp ${TMP_PKG[${PKG[short]}_main]}/changes.XXX)"
	TMP_PKG[${PKG[short]}_key]="$(mktemp ${TMP_PKG[${PKG[short]}_main]}/key.XXX)"
	TMP_PKG[${PKG[short]}_key_output]="$(mktemp ${TMP_PKG[${PKG[short]}_main]}/output.XXX)"
	TMP_PKG[${PKG[short]}_hash_calc]="$(mktemp ${TMP_PKG[${PKG[short]}_main]}/calc.XXX)"
	TMP_PKG[${PKG[short]}_folder]="$(mktemp ${TMP_PKG[${PKG[short]}_main]}/folder.XXX)"

	# log::debug
	log::debug "--- tmp pkg folder for ${PKG[pretty]} ---"
	log::debug "TMP_PKG[main]       | ${TMP_PKG[${PKG[short]}_main]}"
	log::debug "TMP_PKG[pkg]        | ${TMP_PKG[${PKG[short]}_pkg]}"
	log::debug "TMP_PKG[gpg]        | ${TMP_PKG[${PKG[short]}_gpg]}"
	log::debug "TMP_PKG[sig]        | ${TMP_PKG[${PKG[short]}_sig]}"
	log::debug "TMP_PKG[hash]       | ${TMP_PKG[${PKG[short]}_hash]}"
	log::debug "TMP_PKG[changes]    | ${TMP_PKG[${PKG[short]}_changes]}"
	log::debug "TMP_PKG[key]        | ${TMP_PKG[${PKG[short]}_key]}"
	log::debug "TMP_PKG[key_output] | ${TMP_PKG[${PKG[short]}_key_output]}"
	log::debug "TMP_PKG[hash_calc]  | ${TMP_PKG[${PKG[short]}_hash_calc]}"
	log::debug "TMP_PKG[folder]     | ${TMP_PKG[${PKG[short]}_folder]}"
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
	log::debug "starting for: $1"
	pkg::tmp::remove

	map TMP_INFO TMP_INFO[main] TMP_INFO[bash] TMP_INFO[monero] TMP_INFO[p2pool] TMP_INFO[xmrig]

	if [[ $1 = update ]]; then
		TMP_INFO[main]="$(mktemp -d /tmp/monero-bash-info.XXXXXXXXXX)"
		TMP_INFO[bash]="$(mktemp ${TMP_INFO[main]}/bash-info.XXX)"
		[[ $MONERO_VER ]] && TMP_INFO[monero]="$(mktemp ${TMP_INFO[main]}/monero-info.XXX)"
		[[ $P2POOL_VER ]] && TMP_INFO[p2pool]="$(mktemp ${TMP_INFO[main]}/p2pool-info.XXX)"
		[[ $XMRIG_VER ]]  && TMP_INFO[xmrig]="$(mktemp ${TMP_INFO[main]}/xmrig-info.XXX)"
	elif [[ $1 = info ]]; then
		TMP_INFO[main]="$(mktemp -d /tmp/monero-bash-info.XXXXXXXXXX)"
		[[ $UPGRADE_LIST = *bash* ]]     && TMP_INFO[bash]="$(mktemp ${TMP_INFO[main]}/bash-info.XXX)"
		[[ $UPGRADE_LIST = *monero* ]] && TMP_INFO[monero]="$(mktemp ${TMP_INFO[main]}/monero-info.XXX)"
		[[ $UPGRADE_LIST = *p2p* ]]      && TMP_INFO[p2pool]="$(mktemp ${TMP_INFO[main]}/p2pool-info.XXX)"
		[[ $UPGRADE_LIST = *xmr* ]]      && TMP_INFO[xmrig]="$(mktemp ${TMP_INFO[main]}/xmrig-info.XXX)"
	fi

	# log::debug
	log::debug "--- tmp info folder ---"
	log::debug "TMP_INFO[main]   | ${TMP_INFO[main]}"
	log::debug "TMP_INFO[bash]   | ${TMP_INFO[bash]}"
	log::debug "TMP_INFO[monero] | ${TMP_INFO[monero]}"
	log::debug "TMP_INFO[p2pool] | ${TMP_INFO[p2pool]}"
	log::debug "TMP_INFO[xmrig]  | ${TMP_INFO[xmrig]}"
	return 0
}

# remove monero-bash temp files
pkg::tmp::remove() {
	log::debug "starting"
	if find /tmp/monero-bash* &>/dev/null; then
		log::debug "old tmp folders found, removing"
		if rm -rf /tmp/monero-bash*; then
			log::debug "rm tmp folder OK"
		else
			log::debug "rm tmp folder FAIL"
			return 1
		fi
	else
		log::debug "no old tmp folders found, skipping"
	fi
}
