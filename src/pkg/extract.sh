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
# ALSO copies extracted folder contents
# into the packages folder.
pkg::extract() {
	log::debug "starting"

	local i

	# start multi-threaded download per package
	# into it's own ${TMP_PKG[pkg]} folder
	# and remove tar.
	for i in $UPGRADE_LIST; do
		struct::pkg $i
		pkg::extract::multi & JOB[${i}_extract]=$!
	done

	# WAIT FOR THREADS
	for i in $UPGRADE_LIST_SIZE; do
		log::debug "${PKG[pretty]} | waiting for extraction/copy thread to complete"
		struct::pkg $i
		log::prog "${PKG[pretty]}"
		wait -f ${JOB[${i}_extract]} || :
		# CHECK FAIL FILES
		log::debug "${PKG[pretty]} | checking for failure files"
		[[ -e "${TMP_PKG[${PKG[short]}_main]}"/FAIL_EXTRACT ]] && echo && print::exit "Upgrade failure | ${PKG[pretty]} tar extraction failed"
		[[ -e "${TMP_PKG[${PKG[short]}_main]}"/FAIL_RM ]]      && echo && print::exit "Upgrade failure | ${PKG[pretty]} tar removal failed"
		[[ -e "${TMP_PKG[${PKG[short]}_main]}"/FAIL_LS ]]      && echo && print::exit "Upgrade failure | ${PKG[pretty]} NULL folder variable"
		[[ -e "${TMP_PKG[${PKG[short]}_main]}"/FAIL_CP ]]      && echo && print::exit "Upgrade failure | ${PKG[pretty]} copy failed"
		log::ok "${PKG[pretty]}"
		log::debug "${PKG[pretty]} | no failure files found"
	done
	return 0
}

pkg::extract::multi() {
	log::debug "${PKG[pretty]} | starting extraction thread"

	# extract
	if tar -xf "${TMP_PKG[${PKG[short]}_tar]}" -C "${TMP_PKG[${PKG[short]}_pkg]}" &>/dev/null; then
		log::debug "${PKG[pretty]} | tar extract OK | ${TMP_PKG[${PKG[short]}_tar]}"
	else
		touch "${TMP_PKG[${PKG[short]}_main]}/FAIL_EXTRACT" &>/dev/null || exit 1
		log::debug "${PKG[pretty]} | tar extract FAIL | ${TMP_PKG[${PKG[short]}_tar]}"
	fi

	# remove tar
	if rm "${TMP_PKG[${PKG[short]}_tar]}" &>/dev/null; then
		log::debug "${PKG[pretty]} | tar rm OK | ${TMP_PKG[${PKG[short]}_tar]}"
	else
		touch "${TMP_PKG[${PKG[short]}_main]}/FAIL_RM" &>/dev/null || exit 2
		log::debug "${PKG[pretty]} | tar rm FAIL | ${TMP_PKG[${PKG[short]}_tar]}"
	fi

	# get folder name
	TMP_PKG[${PKG[short]}_folder]="$(ls ${TMP_PKG[${PKG[short]}_pkg]})"
	TMP_PKG[${PKG[short]}_folder]="${TMP_PKG[${PKG[short]}_pkg]}/${TMP_PKG[${PKG[short]}_folder]}"
	log::debug "package folder: ${TMP_PKG[${PKG[short]}_folder]}"

	# NULL folder name sanity check
	if [[ -z ${TMP_PKG[${PKG[short]}_folder]} || ${TMP_PKG[${PKG[short]}_folder]} =~ ^[[:space:]]+$ ]]; then
		touch "${TMP_PKG[${PKG[short]}_main]}/FAIL_LS" &>/dev/null || exit 2
		log::debug "${PKG[pretty]} | NULL folder variable"
	fi

	# copy to folder
	mkdir -p "${PKG[directory]}"
	if cp -fr "${TMP_PKG[${PKG[short]}_folder]}"/* "${PKG[directory]}"; then
		log::debug "copied ${TMP_PKG[${PKG[short]}_folder]} contents into ${PKG[directory]}"
	else
		touch "${TMP_PKG[${PKG[short]}_main]}/FAIL_CP" &>/dev/null || exit 2
		log::debug "${PKG[pretty]} | cp folder FAIL"
	fi
}
