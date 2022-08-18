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

# order of operations:
# 1. Send request to GitHub API
# 2. Save output as $DUMP variable (to reuse later)
# 3. GitHub will often rate-limit VPNs/Tor: if so, download HTML dump of regular link
# 4. Filter output for latest release download
# 5. wget the found download link

download_Template()
{
	# if API fetch fails, use HTML dump instead
	API="true"
	HTML="false"
	DUMP="$(wget -qO- "https://api.github.com/repos/$AUTHOR/$PROJECT/releases/latest")"
	if [[ $? != "0" ]]; then
		IRED; echo "GitHub API error detected..."
		OFF; echo "Trying GitHub HTML filter instead..."
		DUMP="$(wget -qO- "https://github.com/$AUTHOR/$PROJECT/releases/latest")"
		API="false"
		HTML="true"
	fi

	# if downloading Monero, just use the static getmonero.org link
	if [[ $downloadMonero = "true" ]]; then
		LINK="https://downloads.getmonero.org/cli/linux64"
		wget -P "$tmp" -q --show-progress --content-disposition "$LINK"
		code_Wget
	else

	# else, search for the download link on github
		if [[ "$HTML" = "true" ]]; then
			LINK="$(echo "$DUMP" \
				| grep -o "/$AUTHOR/$PROJECT/releases/download/.*/$DOT_PKG" \
				| awk '{print $1}' \
				| tr -d '"' \
				| sed 's@^@https://github.com@')"
		else
			LINK="$(echo "$DUMP" \
				| grep -o "https://github.com/$AUTHOR/$PROJECT/releases/download/.*/$DOT_PKG" \
				| tr -d '"')"
		fi
		wget -P "$tmp" -q --show-progress "$LINK"
		code_Wget
	fi
}
