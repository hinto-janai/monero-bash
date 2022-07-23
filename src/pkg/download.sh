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

# order of operations:
#     1. Create array of packages
#     2. Create tmp folder for each package
#     3. Send request to GitHub API for each package
#     4. Save output into $DUMP array (to reuse later)
#     5. GitHub will often rate-limit VPNs/Tor: if so, download HTML dump of regular link
#     6. Filter output for latest release download
#     7. wget/curl the found download link
pkg::download() {
true
#	# if API fetch fails, use HTML dump instead
#	API="true"
#	HTML="false"
#	DUMP="$(wget -qO- "https://api.github.com/repos/$AUTHOR/$PROJECT/releases/latest")"
#	if [[ $? != "0" ]]; then
#		$ired; echo "GitHub API error detected..."
#		$white; echo "Trying GitHub HTML filter instead..."
#		DUMP="$(wget -qO- "https://github.com/$AUTHOR/$PROJECT/releases/latest")"
#		API="false"
#		HTML="true"
#	fi
#
#	# if downloading Monero, just use the static getmonero.org link
#	if [[ $downloadMonero = "true" ]]; then
#		LINK="https://downloads.getmonero.org/cli/linux64"
#		wget -P "$tmp" -q --show-progress --content-disposition "$LINK"
#		code_Wget
#	else
#
#	# else, search for the download link on github
#		if [[ "$HTML" = "true" ]]; then
#			LINK="$(echo "$DUMP" \
#				| grep -o "/$AUTHOR/$PROJECT/releases/download/.*/$DOT_PKG" \
#				| awk '{print $1}' \
#				| tr -d '"' \
#				| sed 's@^@https://github.com@')"
#		else
#			LINK="$(echo "$DUMP" \
#				| grep -o "https://github.com/$AUTHOR/$PROJECT/releases/download/.*/$DOT_PKG" \
#				| tr -d '"')"
#		fi
#		wget -P "$tmp" -q --show-progress "$LINK"
#		code_Wget
#	fi
}
