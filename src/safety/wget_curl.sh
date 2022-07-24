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

# safety check for wget/curl
# and set global variable
safety::wget_curl() {
	log::debug "starting ${FUNCNAME}()"

	char DOWNLOAD_CMD WGET CURL
	if hash wget &>/dev/null; then
		WGET=true
		DOWNLOAD_CMD="wget --quiet --show-progress --content-disposition -P"
		DOWNLOAD_DIR="wget --quiet --content-disposition -P"
		DOWNLOAD_OUT="wget --quiet -O"
		log::debug "wget found"
		log::debug "DOWNLOAD_CMD | $DOWNLOAD_CMD"
		log::debug "DOWNLOAD_DIR | $DOWNLOAD_DIR"
		log::debug "DOWNLOAD_OUT | $DOWNLOAD_OUT"
	elif hash curl &>/dev/null; then
		CURL=true
		DOWNLOAD_CMD="curl --progress-bar -L -O --output-dir"
		DOWNLOAD_DIR="curl --silent -L -O --output-dir"
		DOWNLOAD_OUT="curl --silent -L --output"
		log::debug "curl found"
		log::debug "DOWNLOAD_CMD | $DOWNLOAD_CMD"
		log::debug "DOWNLOAD_DIR | $DOWNLOAD_DIR"
		log::debug "DOWNLOAD_OUT | $DOWNLOAD_OUT"
	fi
	const::char DOWNLOAD_CMD CURL WGET

	if [[ -z $WGET && -z $CURL ]]; then
		print::error "both [wget] and [curl] were not found!"
		print::error "monero-bash needs at least one to install packages"
		print::exit  "Exiting for safety..."
	else
		return 0
	fi
}
