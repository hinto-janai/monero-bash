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
	log::debug "starting ${FUNCNAME}()"

	# start multi-threaded download per package
	# into it's own ${TMP_PKG[main]} folder
	if [[ $MONERO_BASH_OLD = true ]]; then
		struct::pkg bash
		pkg::tmp::download
		pkg::download::multi &
	fi
	if [[ $MONERO_OLD ]]; then
		struct::pkg monero
		pkg::tmp::download
		pkg::download::multi &
	fi
	if [[ $P2POOL_OLD ]]; then
		struct::pkg p2pool
		pkg::tmp::download
		pkg::download::multi &
	fi
	if [[ $XMRIG_OLD ]]; then
		struct::pkg xmrig
		pkg::tmp::download
		pkg::download::multi &
	fi

	# WAIT FOR THREADS
	log::debug "waiting for download threads to complete"
	if ! wait -n; then
		print::exit "Upgrade failure - download failed"
	fi

	return 0
}

# download all links provided by pkg::info()
# sets the $TMP_PKG[${PKG[short]}_tar] variable
pkg::download::multi() {
	log::debug "starting download thread for: ${PKG[pretty]}"
	[[ ${PKG[name]} = xmrig ]] && $DOWNLOAD_OUT "$TMP_PKG[${PKG[short]}_sig]}" "$LINK_SIG" &
	$DOWNLOAD_OUT "$TMP_PKG[${PKG[short]}_hash]}" "$LINK_HASH" &
	$DOWNLOAD_CMD "$TMP_PKG[${PKG[short]}_pkg]}" "$LINK_PKG" &

	TMP_PKG[${PKG[short]}_tar]="$(ls ${TMP_PKG[${PKG[short]}_pkg]})"
	TMP_PKG[${PKG[short]}_tar]="${TMP_PKG[${PKG[short]}_pkg]}/${TMP_PKG[${PKG[short]}_tar]}"
}
