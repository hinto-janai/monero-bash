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

# this downloads all the links provided by pkg::info().
# including: tar file
#            hash file
#            signature file
#
# downloads are multi-threaded per package.
pkg::download() {
	log::debug "starting"

	unset -v JOB
	declare -A JOB
	local i j t

	# start multi-threaded download per package
	# into it's own ${TMP_PKG[main]} folder
	for i in ${UPGRADE_LIST[@]}; do
		struct::pkg $i
		pkg::tmp::download
		pkg::tmp::multi & JOB[${PKG[short]}]=$!
	done

	# WAIT FOR THREADS
	log::debug "waiting for download threads to complete"
	for j in ${JOB[@]}; do
		wait -n $j || print::exit "Upgrade failure - download process failed"
	done

	# DEFINE TAR PATH VARIABLE
	for t in ${UPGRADE_LIST[@]}; do
		struct::pkg $t
		pkg::download::tar
	done

	return 0
}

# download all links provided by pkg::info()
pkg::download::multi() {
	log::debug "starting download thread for: ${PKG[pretty]}"

	declare -A MULTI_JOB

	[[ ${PKG[name]} = xmrig ]] && $DOWNLOAD_OUT "${TMP_PKG[${PKG[short]}_sig]}" "${LINK_SIG[${PKG[short]}]}" & MULTI_JOB[sig]=$!
	$DOWNLOAD_OUT "${TMP_PKG[${PKG[short]}_hash]}" "${LINK_HASH[${PKG[short]}]}" & MULTI_JOB[hash]=$!
	$DOWNLOAD_CMD "${TMP_PKG[${PKG[short]}_pkg]}" "${LINK_DOWN[${PKG[short]}]}" & MULTI_JOB[pkg]=$!

	if [[ ${PKG[name]} = xmrig ]]; then
		wait -n ${MULTI_JOB[sig]}  || print::exit "Upgrade failure - ${PKG[pretty]} signature download failed"
	fi
	wait -n ${MULTI_JOB[hash]} || print::exit "Upgrade failure - ${PKG[pretty]} hash download failed"
	wait -n ${MULTI_JOB[pkg]}  || print::exit "Upgrade failure - ${PKG[pretty]} package download failed"
}

# sets the $TMP_PKG[${PKG[short]}_tar] variable
pkg::download::tar() {
	log::debug "starting: ${PKG[pretty]}"

	map TMP_PKG[${PKG[short]}_tar]

	TMP_PKG[${PKG[short]}_tar]="$(ls ${TMP_PKG[${PKG[short]}_pkg]})"
	TMP_PKG[${PKG[short]}_tar]="${TMP_PKG[${PKG[short]}_pkg]}/${TMP_PKG[${PKG[short]}_tar]}"
	log::debug "downloaded tar: ${TMP_PKG[${PKG[short]}_tar]}"
}
