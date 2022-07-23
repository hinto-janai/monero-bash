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

# handle creation/removal of cryptographic key files
# currently used for encrypting wallet passwords
# assumes trace() is already set.
# called from: wallet/start.sh
crypto::key::create() {
	log::debug "creating one-time key with 4096 bits of entropy"

	# CREATE KEY FILE
	char CRYPTO_KEY
	CRYPTO_KEY=$(mktemp /tmp/monero-bash-crypto-key.XXXXXXXXXX)
	chmod 600 "$CRYPTO_KEY"

	# 4096 BITS / 512 BYTES OF ENTROPY
	crypto::bytes 512 | base64 > "$CRYPTO_KEY"

	log::debug "created one-time key: $CRYPTO_KEY"
	return 0
}

crypto::key::remove() {
	log::debug "deleting one-time key: $CRYPTO_KEY"

	# CHECK IF EXISTS
	[[ -e $CRYPTO_KEY ]]

	# REMOVE
	rm "$CRYPTO_KEY"
	free CRYPTO_KEY
}
