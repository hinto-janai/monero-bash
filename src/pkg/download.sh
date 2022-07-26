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

	local i

	# start multi-threaded download per package
	# into it's own ${TMP_PKG[main]} folder
	for i in $UPGRADE_LIST; do
		struct::pkg $i
		pkg::tmp::download
		if [[ ${PKG[short]} = xmrig ]]; then
			pkg::download::sig & JOB[${i}_download_sig]=$!
		fi
		pkg::download::hash & JOB[${i}_download_hash]=$!
		pkg::download::pkg & JOB[${i}_download_pkg]=$!
	done

	# WAIT FOR THREADS
	# change order from smallest pkg to biggest
	char UPGRADE_LIST_SIZE
	[[ $UPGRADE_LIST = *bash* ]]   && UPGRADE_LIST_SIZE="bash"
	[[ $UPGRADE_LIST = *p2pool* ]] && UPGRADE_LIST_SIZE="$UPGRADE_LIST_SIZE p2pool"
	[[ $UPGRADE_LIST = *xmrig* ]]  && UPGRADE_LIST_SIZE="$UPGRADE_LIST_SIZE xmrig"
	[[ $UPGRADE_LIST = *monero* ]] && UPGRADE_LIST_SIZE="$UPGRADE_LIST_SIZE monero"
	for i in $UPGRADE_LIST_SIZE; do
		log::debug "${PKG[pretty]} | waiting for download threads to complete"
		struct::pkg $i
		log::prog "${PKG[pretty]} | ${LINK_DOWN[${PKG[short]}]}"
		wait -f ${JOB[${i}_download_hash]} ${JOB[${i}_download_pkg]}
		[[ ${PKG[short]} = xmrig ]] && wait -f ${JOB[${i}_download_sig]}
		log::ok "${PKG[pretty]} | ${LINK_DOWN[${PKG[short]}]}"
	done

	# CHECK FAIL FILES
	log::debug "checking for failure files"
	for i in $UPGRADE_LIST; do
		struct::pkg $i
		[[ -e "${TMP_PKG[${PKG[short]}_main]}"/FAIL_DOWNLOAD_SIG ]]  && print::exit "Upgrade failure | ${PKG[pretty]} signature download failed"
		[[ -e "${TMP_PKG[${PKG[short]}_main]}"/FAIL_DOWNLOAD_HASH ]] && print::exit "Upgrade failure | ${PKG[pretty]} hash download failed"
		[[ -e "${TMP_PKG[${PKG[short]}_main]}"/FAIL_DOWNLOAD_PKG ]]  && print::exit "Upgrade failure | ${PKG[pretty]} package download failed"
		log::debug "${PKG[pretty]} | no failure files found"
	done

	# DEFINE TAR PATH VARIABLE
	for i in $UPGRADE_LIST; do
		struct::pkg $i
		pkg::download::find_tar
	done

	return 0
}

# download links provided by pkg::info()
pkg::download::sig() {
	log::debug "${PKG[pretty]} | starting sig download thread"
	if $DOWNLOAD_OUT "${TMP_PKG[${PKG[short]}_sig]}" "${LINK_SIG[${PKG[short]}]}"; then
		log::debug "${PKG[pretty]} | sig download OK"
	else
		log::debug "${PKG[pretty]} | sig download FAIL"
		touch "${TMP_PKG[${PKG[short]}_main]}/FAIL_DOWNLOAD_SIG" &>/dev/null || exit 1
	fi
}

pkg::download::hash() {
	log::debug "${PKG[pretty]} | starting hash download thread"
	if $DOWNLOAD_OUT "${TMP_PKG[${PKG[short]}_hash]}" "${LINK_HASH[${PKG[short]}]}"; then
		log::debug "${PKG[pretty]} | hash download OK"
	else
		log::debug "${PKG[pretty]} | hash download FAIL"
		touch "${TMP_PKG[${PKG[short]}_main]}/FAIL_DOWNLOAD_HASH" &>/dev/null || exit 2
	fi
}

pkg::download::pkg() {
	log::debug "${PKG[pretty]} | starting pkg download thread"

	# some curl version don't support --output-dir,
	# so, cd and download in a subshell.
	if [[ $CURL = true ]]; then
		if (cd "${TMP_PKG[${PKG[short]}_pkg]}" && $DOWNLOAD_DIR "${LINK_DOWN[${PKG[short]}]}"); then
			log::debug "${PKG[pretty]} | pkg download OK"
		else
			log::debug "${PKG[pretty]} | pkg download FAIL"
			touch "${TMP_PKG[${PKG[short]}_main]}/FAIL_DOWNLOAD_PKG" &>/dev/null || exit 3
		fi
	else
		if $DOWNLOAD_DIR "${TMP_PKG[${PKG[short]}_pkg]}" "${LINK_DOWN[${PKG[short]}]}"; then
			log::debug "${PKG[pretty]} | pkg download OK"
		else
			log::debug "${PKG[pretty]} | pkg download FAIL"
			touch "${TMP_PKG[${PKG[short]}_main]}/FAIL_DOWNLOAD_PKG" &>/dev/null || exit 4
		fi
	fi
}

# sets the $TMP_PKG[${PKG[short]}_tar] variable
pkg::download::find_tar() {
	log::debug "${PKG[pretty]} | starting"

	map TMP_PKG[${PKG[short]}_tar]

	TMP_PKG[${PKG[short]}_tar]="$(ls ${TMP_PKG[${PKG[short]}_pkg]})"
	TMP_PKG[${PKG[short]}_tar]="${TMP_PKG[${PKG[short]}_pkg]}/${TMP_PKG[${PKG[short]}_tar]}"
	log::debug "downloaded tar: ${TMP_PKG[${PKG[short]}_tar]}"
}
