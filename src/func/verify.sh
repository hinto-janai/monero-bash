# This file is part of [monero-bash]
#
# Copyright (c) 2022 hinto.janaiyo
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
#
# Parts of this project are originally:
# Copyright (c) 2019-2022, jtgrassie
# Copyright (c) 2014-2022, The Monero Project


# hash & GPG verification of binaries
#
# everyone has a slightly differently named sha256sum
# file, with slightly different internal formatting
# which makes this function a bit long.
#
# the order of operations is the same as the "download_Template" function
# but instead it's downloading the SHA256SUM file and
# filtering it to find the proper hash to compare against

verify_Template()
{
	# api or html? (or are we downloading monero?)
	if [[ "$HTML" = "true" && "$downloadMonero" != "true" ]]; then
		hashLink="$(echo "$DUMP" \
		| grep -o "/$AUTHOR/$PROJECT/releases/download/.*/$SHA" \
		| head -n1 \
		| awk '{print $1}' \
		| tr -d '"' \
		| sed 's@^@https://github.com@')"
	elif [[ "$API" = "true" && "$downloadMonero" != "true" ]]; then
		hashLink="$(echo "$DUMP" \
			| grep "browser_download_url.*$SHA" \
			| awk '{print $2}' | head -n1 | tr -d '"')"
	else
		hashLink="https://www.getmonero.org/downloads/hashes.txt"
	fi

	# setting of the tmp file variables (and gpg)
	tarFile="$(ls "$tmp")"
	wget -q -P "$tmpHash" "$hashLink"
	code_Wget
	hashFile="$(ls "$tmpHash")"
	sigFile="$hashFile"
	hashSTDOUT="$(cat "$tmpHash/$hashFile")"

    # check if gpg key is imported
    if ! gpg --list-keys "$FINGERPRINT" &>/dev/null ;then
        $off; echo "Importing [${GPG_OWNER}]'s PGP key..."
        gpg_import_Template
    fi

	# xmrig author pls include the sig in the hash file
	if [[ $downloadXMRig = "true" ]]; then
		if [[ $HTML = "true" ]]; then
			sigLink="$(echo "$DUMP" \
			| grep -o "/$AUTHOR/$PROJECT/releases/download/.*/$SIG" \
			| head -n1 \
			| awk '{print $1}' \
			| tr -d '"' \
			| sed 's@^@https://github.com@')"
		elif [[ "$API" = "true" ]]; then
			sigLink="$(echo "$DUMP" \
			| grep "browser_download_url.*$SIG" \
			| awk '{print $2}' | head -n1 | tr -d '"')"
		fi
		wget -q -P "$tmpSig" "$sigLink"
		code_Wget
		sigFile="$(ls "$tmpSig")"
	fi
	hashSTDOUT="$(wget -qO- "$hashLink")"

	# comparison of hashes (and are we downloading p2pool?)
	if [[ $downloadP2Pool = "true" ]]; then
		HASH="$(echo "$hashSTDOUT" | grep -A2 "$DOT_PKG" | grep "SHA256" | awk '{print $2}')"
	else
		HASH="$(echo "$hashSTDOUT" | grep "$DOT_PKG" | awk '{print $1}')"
	fi
	[[ -z $HASH ]] && error_Exit "Hash file was empty"
	echo "$HASH" "$tmp/$tarFile" | sha256sum -c &>/dev/null
	print_OKFAILED
	if [[ "$verifyOK" != "true" ]]; then
		LOCAL_HASH="$(sha256sum "$tmp/$tarFile" | awk '{print $1}' | tr -d " -")"
		compromised_Hash
	fi

	# gpg check
	if [[ $downloadXMRig = "true" ]]; then
		gpg --verify "$tmpSig/$sigFile" "$tmpHash/$hashFile" &> "$tmpGPG"
		print_GPG
	else
		gpg --verify "$tmpHash/$sigFile" &> "$tmpGPG"
		print_GPG
	fi
	gpgSTDOUT="$(cat /tmp/monero-bash-gpg.*)"
	if [[ "$gpgOK" != "true" ]]; then
		LOCAL_HASH="$(sha256sum "$tmp/$tarFile" | awk '{print $1}' | tr -d " -")"
		compromised_GPG
	fi
}
