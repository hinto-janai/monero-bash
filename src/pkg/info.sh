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
# Also gets package metadata information:
#     "tag_name"
#     "created_at"
#     "body"
#
# uses functions from pkg::update()
pkg::info() {
	log::debug "starting"

	# VARIABLE AND TMP
	pkg::tmp::info info
	map VER RELEASE BODY LINK_DOWN LINK_HASH LINK_SIG
	local UPDATE_FOUND i j
	declare -a SCRATCH

	# MULTI-THREAD PKG METADATA DOWNLOAD
	for i in $UPGRADE_LIST; do
		struct::pkg $i
		pkg::update::multi & JOB[${i}_update]=$!
	done

	# WAIT FOR THREADS
	log::debug "waiting for metadata threads to complete"
	wait -f ${JOB[@]} || :

	# CHECK FAIL FILES
	log::debug "checking for failure files"
	for i in $UPGRADE_LIST; do
		struct::pkg $i
		if [[ -e "${TMP_INFO[main]}/FAIL_UPDATE_${PKG[var]}" ]]; then
			log::debug "${PKG[pretty]} | metadata fetch failed"
			local UPDATE_FAILED=true
		fi
	done
	if [[ $UPDATE_FAILED = true ]]; then
		echo
		print::error "Upgrade failure | Metadata fetch from GitHub API failed"
		print::exit "Are you using a VPN/TOR? GitHub API will often rate-limit them."
	fi
	log::debug "no failure files found"


	# FILTER VERSION VARIABLE $VER[${PKG[short]}}
	for i in $UPGRADE_LIST; do
		struct::pkg $i
		pkg::update::ver
		pkg::info::down
		pkg::info::hash
		pkg::info::sig
		pkg::info::changes
		if [[ ${PKG[short]} = bash && ${VER[${PKG[short]}]} != v2* ]]; then
			log::debug "${PKG[pretty]} | new version found != v2* | printing EOL message"
			print::eol
			UPGRADE_LIST="${UPGRADE_LIST//bash}"
		fi
	done
}

# filter for the package download link
pkg::info::down() {
	log::debug "starting: ${PKG[pretty]}"

	# use static link for [Monero]
	if [[ ${PKG[name]} = monero ]]; then
		LINK_DOWN[${PKG[short]}]="https://downloads.getmonero.org/cli/linux64"
		log::debug "package Monero detected, LINK_DOWN: ${LINK_DOWN[${PKG[short]}]}"
		return 0
	fi

	LINK_DOWN[${PKG[short]}]="$(grep -o "https://github.com/${PKG[author]}/${PKG[name]}/releases/download/${VER[${PKG[short]}]}/${PKG[regex]}" "${TMP_INFO[${PKG[short]}]}")"
	LINK_DOWN[${PKG[short]}]="${LINK_DOWN[${PKG[short]}]//\"}"
	log::debug "${PKG[pretty]} download link found: ${LINK_DOWN[${PKG[short]}]}"
}

# create the hash link out of existing variables
pkg::info::hash() {
	log::debug "starting: ${PKG[pretty]}"

	# use static link for [Monero]
	if [[ ${PKG[name]} = monero ]]; then
		LINK_HASH[${PKG[short]}]="https://www.getmonero.org/downloads/hashes.txt"
		log::debug "package Monero detected, LINK_HASH: ${LINK_HASH[${PKG[short]}]}"
		return 0
	fi

	LINK_HASH[${PKG[short]}]="https://github.com/${PKG[author]}/${PKG[name]}/releases/download/${VER[${PKG[short]}]}/${PKG[hash]}"
	log::debug "${PKG[pretty]} hash link: ${LINK_HASH[${PKG[short]}]}"
}

# create the sig link out of existing variables
# only used for XMRig, everyone else has the
# signature within the hash file.
pkg::info::sig() {
	log::debug "starting: ${PKG[pretty]}"

	LINK_SIG[${PKG[short]}]="https://github.com/${PKG[author]}/${PKG[name]}/releases/download/${VER[${PKG[short]}]}/${PKG[sig]}"
	log::debug "${PKG[pretty]} sig link: ${LINK_SIG[${PKG[short]}]}"
}

# gain metadata about package:
#     - creation time
#     - BODY of the GitHub release.
#
# used to create local CHANGELOG files.
pkg::info::changes() {
	log::debug "starting: ${PKG[pretty]}"

	# created_at (release time)
	RELEASE[${PKG[short]}]="$(grep -m 1 "\"created_at\":" "${TMP_INFO[${PKG[short]}]}")"
	RELEASE[${PKG[short]}]="${RELEASE[${PKG[short]}]//*\"created_at\": }"
	RELEASE[${PKG[short]}]="${RELEASE[${PKG[short]}]//\"}"
	RELEASE[${PKG[short]}]="${RELEASE[${PKG[short]}]//,}"
	RELEASE[${PKG[short]}]="${RELEASE[${PKG[short]}]//T/ }"
	RELEASE[${PKG[short]}]="${RELEASE[${PKG[short]}]//Z/}"
	log::debug "${PKG[pretty]} RELEASE: ${RELEASE[${PKG[short]}]}"

	# body (GitHub description, changelog)
	BODY[${PKG[short]}]="$(grep -m 1 "\"body\":" "${TMP_INFO[${PKG[short]}]}")"
	BODY[${PKG[short]}]="${BODY[${PKG[short]}]//*\"body\": \"}"
	BODY[${PKG[short]}]="${BODY[${PKG[short]}]:0:-2}"
	BODY[${PKG[short]}]="${BODY[${PKG[short]}]//\\r\\n/$'\n'}"

	log::debug "${PKG[pretty]} BODY: OK"
}
