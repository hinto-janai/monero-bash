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
	log::debug "starting ${FUNCNAME}()"

	# CHECK FOR PGP KEY
	if [[ $MONERO_BASH_OLD = true ]]; then
		struct::pkg bash
		pkg::verify::key
	fi
	if [[ $MONERO_OLD ]]; then
		struct::pkg monero
		pkg::verify::key
	fi
	if [[ $P2POOL_OLD ]]; then
		struct::pkg p2pool
		pkg::verify::key
	fi
	if [[ $XMRIG_OLD ]]; then
		struct::pkg xmrig
		pkg::verify::key
	fi

	# CALCULATE HASH
	map HASH
	if [[ $MONERO_BASH_OLD = true ]]; then
		struct::pkg bash
		pkg::verify::hash_calc &
	fi
	if [[ $MONERO_OLD ]]; then
		struct::pkg monero
		pkg::verify::hash_calc &
	fi
	if [[ $P2POOL_OLD ]]; then
		struct::pkg p2pool
		pkg::verify::hash_calc &
	fi
	if [[ $XMRIG_OLD ]]; then
		struct::pkg xmrig
		pkg::verify::hash_calc &
	fi

	# VERIFY HASH AND PGP
	if [[ $MONERO_BASH_OLD = true ]]; then
		struct::pkg bash
		pkg::verify::hash
		pkg::verify::pgp
	fi
	if [[ $MONERO_OLD ]]; then
		struct::pkg monero
		pkg::verify::hash
		pkg::verify::pgp
	fi
	if [[ $P2POOL_OLD ]]; then
		struct::pkg p2pool
		pkg::verify::hash
		pkg::verify::pgp
	fi
	if [[ $XMRIG_OLD ]]; then
		struct::pkg xmrig
		pkg::verify::hash
		pkg::verify::pgp
	fi
}

# check for ${PKG[gpg_owner]} keys
# import if not found.
pkg::verify::key() {
	log::debug "starting ${FUNCNAME}() for: ${PKG[pretty]}"

	if gpg --list-keys "${PKG[fingerprint]}" &>/dev/null; then
		log::debug "PGP key found: ${PKG[gpg_owner]} - ${PKG[fingerprint]}"
	else
		log::debug "PGP key not found: ${PKG[gpg_owner]} - ${PKG[fingerprint]}"
		log::debug "Importing from: $PKG_MONERO_BASH/gpg/${PKG[gpg_owner]}.asc"
		gpg --quiet --import "$PKG_MONERO_BASH/gpg/${PKG[gpg_owner]}.asc"
	fi
}

# calculate hash of the downloaded tar.
pkg::verify::hash_calc() {
	log::debug "starting ${FUNCNAME}() for: ${PKG[pretty]}"
	HASH[${PKG[short]}]=$(sha256sum "${TMP_PKG[${PKG[short]}_tar]}")
}

# look for a matching hash in the hash file.
pkg::verify::hash() {
	log::debug "starting ${FUNCNAME}() for: ${PKG[pretty]}"
	log::prog "${PKG[pretty]} HASH..."

	# grep for hash in hash file
	if grep -o "${HASH[${PKG[short]}]}" "${TMP_PKG[${PKG[short]}_hash]}" &>/dev/null; then
		log::debug "${PKG[pretty]} hash match found: ${TMP_PKG[${PKG[short]}_hash]}"

		# calculate first and last 6 digits of hash
		local HASH_START HASH_END HASH_DIGIT
		HASH_DIGIT="${#TMP_PKG[${PKG[short]}_hash]}"
		HASH_START="${TMP_PKG[${PKG[short]}_hash]:0:6}"
		HASH_END="$((HASH_DIGIT-6))"
		HASH_END="${TMP_PKG[${PKG[short]}_hash]:${HASH_END}}"
		log::ok "${PKG[pretty]} HASH: ${HASH_START}...${HASH_END}"

	# else exit on incorrect hash
	else
		print::compromised::hash
		exit 1
	fi
}

# verify pgp signature
pkg::verify::pgp() {
	log::debug "starting ${FUNCNAME}() for: ${PKG[pretty]}"
	log::prog "${PKG[pretty]} PGP..."

	# XMRig uses a different file, so
	# use [sig] instead of [hash]
	if [[ ${PKG[name]} = xmrig ]]; then
		TMP_PKG[${PKG[short]}_hash]="${TMP_PKG[${PKG[short]}_sig]}"
	fi

	# verify and redirect output to tmp file
	if gpg --verify "${TMP_PKG[${PKG[short]}_hash]}" &> "${TMP_PKG[${PKG[short]}_gpg]}"; then
		log::debug "PGP success: $(cat ${TMP_PKG[${PKG[short]}_gpg]})"
		log::ok "${PKG[pretty]} PGP signed by: ${PKG[gpg_owner]}"
	else
		log::debug "PGP failure"
		print::compromised::pgp
		exit 1
	fi
}
