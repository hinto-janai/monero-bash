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

# filter out the hash and verify the tar.
# import GPG key if not found.
pkg::verify() {
	log::debug "starting"

	# VARIABLES
	local i
	unset -v JOB_HASH
	map HASH
	char VERIFY_MSG

	# CALCULATE HASH AND CHECK FOR PGP KEY
	for i in $UPGRADE_LIST; do
		struct::pkg $i
		pkg::verify::hash_calc & JOB[${PKG[short]}_hash]=$!
		pkg::verify::check_key & JOB[${PKG[short]}_key]=$!
	done

	# WAIT FOR THREADS
	for i in $UPGRADE_LIST; do
		struct::pkg $i
		log::debug "waiting for hash_calc() & check_key() threads to complete"
		if ! wait -f ${JOB[${PKG[short]}_hash]}; then
			print::exit "${PKG[pretty]} | hash calculation failed"
		fi
		if ! wait -f ${JOB[${PKG[short]}_key]}; then
			print::exit "${PKG[pretty]} | ${PKG[gpg_owner]} PGP key download/import failed"
		fi
	done

	# VERIFY HASH AND PGP
	for i in $UPGRADE_LIST; do
		struct::pkg $i
		log::prog "${PKG[pretty]} | HASH ... | PGP Signed by ..."
		pkg::verify::hash &&
		pkg::verify::pgp  &&
		log::ok "${PKG[pretty]} | ${VERIFY_MSG[${PKG[short]}]}" ||
		log::fail "${PKG[pretty]} | ${VERIFY_MSG[${PKG[short]}]}"
	done


}

# calculate hash of the downloaded tar.
pkg::verify::hash_calc() {
	log::debug "starting: ${PKG[pretty]}"
	if sha256sum "${TMP_PKG[${PKG[short]}_tar]}" > "${TMP_PKG[${PKG[short]}_hash_calc]}"; then
		log::debug "${PKG[pretty]} | hash_calc OK"
	else
		log::debug "${PKG[pretty]} | hash_calc FAIL"
		return 1
	fi
}

# check for ${PKG[gpg_owner]} keys
# if not found, start download and import.
pkg::verify::check_key() {
	log::debug "starting: ${PKG[pretty]}"

	if gpg --list-keys "${PKG[fingerprint]}" &>/dev/null; then
		log::debug "PGP key found: ${PKG[gpg_owner]} | ${PKG[fingerprint]}"
	else
		log::debug "PGP key not found: ${PKG[gpg_owner]} | ${PKG[fingerprint]}"
		printf "${BWHITE}%s${BYELLOW}%s${BWHITE}%s${OFF}\n" \
			"Importing " \
			"${PKG[gpg_owner]}'s " \
			"PGP key..."

		log::debug "storing ${PKG[gpg_owner]}.asc into: ${TMP_PKG[${PKG[short]}_key]}"
		log::debug "storing import output into: ${TMP_PKG[${PKG[short]}_key_output]}"

		# start download thread for PGP key (found on github)
		log::debug "${PKG[gpg_owner]} | starting PGP key download thread | ${PKG[gpg_pub_key]}"
		if $DOWNLOAD_OUT "${TMP_PKG[${PKG[short]}_key]}" "${PKG[gpg_pub_key]}"; then
			log::debug "${PKG[gpg_owner]} | PGP key download OK"
		else
			log::debug "${PKG[gpg_owner]} | PGP key download FAIL"
			return 1
		fi

		# import
		if gpg --import "${TMP_PKG[${PKG[short]}_key]}" &> "${TMP_PKG[${PKG[short]}_key_output]}"; then
			log::debug "${PKG[gpg_pub_key]} | PGP key import OK"
		else
			log::debug "${PKG[gpg_pub_key]} | PGP key import FAIL"
			return 2
		fi

		# log::debug for key import output
		local IMPORT_KEY_OUTPUT i IFS=$'\n'
		mapfile IMPORT_KEY_OUTPUT < "${TMP_PKG[${PKG[short]}_key_output]}"
		log::debug "--- imported ${PKG[gpg_owner]}'s PGP key ---"
		for i in ${IMPORT_KEY_OUTPUT[@]}; do
			log::debug "$i"
		done
	fi
}

# look for a matching hash in the hash file.
pkg::verify::hash() {
	log::debug "starting: ${PKG[pretty]}"

	# tmp hash into variable
	map VERIFY_MSG[${PKG[short]}]
	local VERIFY_HASH
	mapfile VERIFY_HASH < "${TMP_PKG[${PKG[short]}_hash_calc]}"
	HASH[${PKG[short]}]="${VERIFY_HASH// *}"
	log::debug "${PKG[pretty]} HASH | ${HASH[${PKG[short]}]}"

	# null hash sanity check
	if [[ -z ${HASH[${PKG[short]}]} || ${HASH[${PKG[short]}]} =~ ^[[:space:]]+$ ]]; then
		echo
		print::exit "Upgrade failure | NULL Hash variable"
	fi

	# P2Pool has it's hashes in full upper-case
	# this causes an error because sha256sum outputs in
	# lower case, so grep for lower-case, then upper, else error.
	# grep for LOWER CASE hash in hash file
	if grep -o "${HASH[${PKG[short]}],,}" "${TMP_PKG[${PKG[short]}_hash]}" &>/dev/null; then
		log::debug "${PKG[pretty]} | lower-case hash match found"

		# calculate first and last 6 digits of hash
		local HASH_START HASH_END HASH_DIGIT
		HASH_DIGIT="${#HASH[${PKG[short]}]}"
		HASH_START="${HASH[${PKG[short]}]:0:6}"
		HASH_END="$((HASH_DIGIT-6))"
		HASH_END="${HASH[${PKG[short]}]:${HASH_END}}"
		VERIFY_MSG[${PKG[short]}]="HASH: ${HASH_START}...${HASH_END}"

	# UPPER CASE
	elif grep -o "${HASH[${PKG[short]}]^^}" "${TMP_PKG[${PKG[short]}_hash]}" &>/dev/null; then
		log::debug "${PKG[pretty]} | upper-case hash match found"

		# calculate first and last 6 digits of hash
		local HASH_START HASH_END HASH_DIGIT
		HASH_DIGIT="${#HASH[${PKG[short]}]}"
		HASH_START="${HASH[${PKG[short]}]:0:6}"
		HASH_END="$((HASH_DIGIT-6))"
		HASH_END="${HASH[${PKG[short]}]:${HASH_END}}"
		VERIFY_MSG[${PKG[short]}]="HASH: ${HASH_START}...${HASH_END}"

	# else remove from UPGRADE_LIST on incorrect hash
	else
		printf "\r\e[2K"
		print::compromised::hash
		log::debug "${PKG[pretty]} | HASH COMPROMISED | removing from UPGRADE_LIST"
		VERIFY_MSG[${PKG[short]}]="HASH FAIL"
		UPGRADE_LIST="${UPGRADE_LIST//${PKG[short]}}"
		return 1
	fi
}

# verify pgp signature
pkg::verify::pgp() {
	log::debug "starting: ${PKG[pretty]}"

	# SPECIAL CASE FOR XMRIG
	# ----------------------
	# xmrig seperates the signature and
	# hashes, so you need the verify the
	# hash file with the signature.
	# all other packages don't do this.
	if [[ ${PKG[short]} = xmrig ]]; then
		local VERIFY_PGP_CMD="gpg --verify ${TMP_PKG[${PKG[short]}_sig]} ${TMP_PKG[${PKG[short]}_hash]}"
	else
		local VERIFY_PGP_CMD="gpg --verify ${TMP_PKG[${PKG[short]}_hash]}"
	fi

	# verify and redirect output to tmp file
	if $VERIFY_PGP_CMD &> ${TMP_PKG[${PKG[short]}_gpg]}; then
		VERIFY_MSG[${PKG[short]}]="${VERIFY_MSG[${PKG[short]}]} | PGP signed by: ${PKG[gpg_owner]}"

		# get output into variable
		local PGP_OUTPUT IFS=$'\n' i
		mapfile PGP_OUTPUT < "${TMP_PKG[${PKG[short]}_gpg]}"
		# log::debug PGP output
		log::debug "PGP success for ${PKG[gpg_owner]}: ${TMP_PKG[${PKG[short]}_hash]}"
		for i in ${PGP_OUTPUT[@]}; do
			log::debug "$i"
		done

	else
		VERIFY_MSG[${PKG[short]}]="${VERIFY_MSG[${PKG[short]}]} | PGP FAIL: ${PKG[gpg_owner]}"
		# get output into variable
		local PGP_OUTPUT IFS=$'\n' i
		mapfile PGP_OUTPUT < "${TMP_PKG[${PKG[short]}_gpg]}"
		# log::debug PGP output
		log::debug "PGP failure for ${PKG[gpg_owner]}: ${TMP_PKG[${PKG[short]}_hash]}"
		for i in ${PGP_OUTPUT[@]}; do
			log::debug "$i"
		done
		printf "\r\e[2K"
		print::compromised::pgp
		log::debug "${PKG[pretty]} | PGP COMPROMISED | removing from UPGRADE_LIST"
		UPGRADE_LIST="${UPGRADE_LIST//${PKG[short]}}"
		return 1
	fi
}
