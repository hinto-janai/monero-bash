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
	unset -v JOB
	declare -a JOB
	map HASH

	# CALCULATE HASH AND CHECK FOR PGP KEY
	if [[ $UPGRADE_LIST = *bash* ]]; then
		struct::pkg bash
		pkg::verify::hash_calc & JOB[0]=$!
		pkg::verify::check_key & JOB[1]=$!
	fi
	if [[ $UPGRADE_LIST = *monero* ]]; then
		struct::pkg monero
		pkg::verify::hash_calc & JOB[2]=$!
		pkg::verify::check_key & JOB[3]=$!
	fi
	if [[ $UPGRADE_LIST = *p2p* ]]; then
		struct::pkg p2pool
		pkg::verify::hash_calc & JOB[4]=$!
		pkg::verify::check_key & JOB[5]=$!
	fi
	if [[ $UPGRADE_LIST = *xmr* ]]; then
		struct::pkg xmrig
		pkg::verify::hash_calc & JOB[6]=$!
		pkg::verify::check_key & JOB[7]=$!
	fi

	# WAIT FOR THREADS
	log::debug "waiting for hash_calc() & check_key() threads to complete"
	for i in ${JOB[@]}; do
		wait -n $i || print::exit "Upgrade failure - Hash calculation or PGP key download failed"
	done

	# VERIFY HASH AND PGP
	if [[ $UPGRADE_LIST = *bash* ]]; then
		struct::pkg bash
		pkg::verify::hash
		pkg::verify::pgp
	fi
	if [[ $UPGRADE_LIST = *monero* ]]; then
		struct::pkg monero
		pkg::verify::hash
		pkg::verify::pgp
	fi
	if [[ $UPGRADE_LIST = *p2p* ]]; then
		struct::pkg p2pool
		pkg::verify::hash
		pkg::verify::pgp
	fi
	if [[ $UPGRADE_LIST = *xmr* ]]; then
		struct::pkg xmrig
		pkg::verify::hash
		pkg::verify::pgp
	fi
}

# calculate hash of the downloaded tar.
pkg::verify::hash_calc() {
	log::debug "starting: ${PKG[pretty]}"
	sha256sum "${TMP_PKG[${PKG[short]}_tar]}" > "${TMP_PKG[${PKG[short]}_hash_calc]}"
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
		log::debug "starting PGP key download thread for: ${PKG[gpg_pub_key]}"
		$DOWNLOAD_OUT "${TMP_PKG[${PKG[short]}_key]}" "${PKG[gpg_pub_key]}"

		# import
		gpg --import "${TMP_PKG[${PKG[short]}_key]}" &> "${TMP_PKG[${PKG[short]}_key_output]}"

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
	log::prog "${PKG[pretty]} HASH..."

	# tmp hash into variable
	local VERIFY_HASH
	mapfile VERIFY_HASH < "${TMP_PKG[${PKG[short]}_hash_calc]}"
	HASH[${PKG[short]}]="${VERIFY_HASH// *}"
	log::debug "${PKG[pretty]} HASH | ${HASH[${PKG[short]}]}"

	# sanity check
	[[ ${HASH[${PKG[short]}]} =~ ^[[:space:]]+$ ]] && print::exit "Upgrade failure | NULL Hash variable"

	# grep for hash in hash file
	if grep -o "${HASH[${PKG[short]}]}" "${TMP_PKG[${PKG[short]}_hash]}" &>/dev/null; then
		log::debug "${PKG[pretty]} hash match found"

		# calculate first and last 6 digits of hash
		local HASH_START HASH_END HASH_DIGIT
		HASH_DIGIT="${#HASH[${PKG[short]}]}"
		HASH_START="${HASH[${PKG[short]}]:0:6}"
		HASH_END="$((HASH_DIGIT-6))"
		HASH_END="${HASH[${PKG[short]}]:${HASH_END}}"
		log::ok "${PKG[pretty]} HASH: ${HASH_START}...${HASH_END}"

	# else exit on incorrect hash
	else
		print::compromised::hash
		exit 1
	fi
}

# verify pgp signature
pkg::verify::pgp() {
	log::debug "starting: ${PKG[pretty]}"
	log::prog "${PKG[pretty]} PGP..."

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
		log::ok "${PKG[pretty]} PGP signed by: ${PKG[gpg_owner]}"

		# get output into variable
		local PGP_OUTPUT IFS=$'\n' i
		mapfile PGP_OUTPUT < "${TMP_PKG[${PKG[short]}_gpg]}"
		# log::debug PGP output
		log::debug "PGP success for ${PKG[gpg_owner]}: ${TMP_PKG[${PKG[short]}_hash]}"
		for i in ${PGP_OUTPUT[@]}; do
			log::debug "$i"
		done

	else
		# get output into variable
		local PGP_OUTPUT IFS=$'\n' i
		mapfile PGP_OUTPUT < "${TMP_PKG[${PKG[short]}_gpg]}"
		# log::debug PGP output
		log::debug "PGP failure for ${PKG[gpg_owner]}: ${TMP_PKG[${PKG[short]}_hash]}"
		for i in ${PGP_OUTPUT[@]}; do
			log::debug "$i"
		done
		map COMPROMISED[${PKG[short]}]=true
		print::compromised::pgp
	fi
}
