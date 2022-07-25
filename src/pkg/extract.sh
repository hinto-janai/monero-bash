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

# multi-threaded extraction of the
# tar files created by: pkg::download()
# inside of the tmp folders.
pkg::extract() {
	log::debug "starting"

	unset -v JOB
	declare -a JOB
	local i

	# start multi-threaded download per package
	# into it's own ${TMP_PKG[pkg]} folder
	# and remove tar.
	if [[ $UPGRADE_LIST = *bash* ]]; then
		struct::pkg bash
		pkg::extract::multi & JOB[0]=$!
	fi
	if [[ $UPGRADE_LIST = *monero* ]]; then
		struct::pkg monero
		pkg::extract::multi & JOB[1]=$!
	fi
	if [[ $UPGRADE_LIST = *p2p* ]]; then
		struct::pkg p2pool
		pkg::extract::multi & JOB[2]=$!
	fi
	if [[ $UPGRADE_LIST = *xmr* ]]; then
		struct::pkg xmrig
		pkg::extract::multi & JOB[3]=$!
	fi

	# WAIT FOR THREADS
	log::debug "waiting for extraction threads to complete"
	for i in ${JOB[@]}; do
		wait -n $i || print::exit "Upgrade failure - extraction process failed"
	done

	# get folder PKG variable
	if [[ $UPGRADE_LIST = *bash* ]]; then
		struct::pkg bash
		pkg::extract::folder
	fi
	if [[ $UPGRADE_LIST = *monero* ]]; then
		struct::pkg monero
		pkg::extract::folder
	fi
	if [[ $UPGRADE_LIST = *p2p* ]]; then
		struct::pkg p2pool
		pkg::extract::folder
	fi
	if [[ $UPGRADE_LIST = *xmr* ]]; then
		struct::pkg xmrig
		pkg::extract::folder
	fi

	return 0
}

pkg::extract::multi() {
	log::debug "starting extraction thread for: ${PKG[pretty]}"

	# extract
	tar -xf "${TMP_PKG[${PKG[short]}_tar]}" -C "${TMP_PKG[${PKG[short]}_pkg]}"
	log::debug "extraction complete for: ${TMP_PKG[${PKG[short]}_tar]}"

	# remove tar
	rm "${TMP_PKG[${PKG[short]}_tar]}"
	log::debug "removed tar: ${TMP_PKG[${PKG[short]}_tar]}"
}

pkg::extract::folder() {
	# get folder name
	TMP_PKG[${PKG[short]}_folder]="$(ls ${TMP_PKG[${PKG[short]}_pkg]})"
	TMP_PKG[${PKG[short]}_folder]="${TMP_PKG[${PKG[short]}_pkg]}/${TMP_PKG[${PKG[short]}_folder]}"
	log::debug "extracted package folder: ${TMP_PKG[${PKG[short]}_folder]}"
}
