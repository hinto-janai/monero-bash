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

# print size of monero-bash folders
print::size() {
	log::debug "getting folder sizes"
	local SIZE_MONERO_BASH SIZE_MONERO SIZE_P2POOL SIZE_XMRIG SIZE_BITMONERO SIZE_DOT || return 1
	SIZE_MONERO_BASH=$(du -h "$PKG_MONERO_BASH")
	SIZE_MONERO=$(du -h "$PKG_MONERO")
	SIZE_P2POOL=$(du -h "$PKG_P2POOL")
	SIZE_XMRIG=$(du -h "$PKG_XMRIG")
	SIZE_DOT=$(du -h "$DOT")
	if [[ -d "$HOME/.bitmonero" ]]; then
		SIZE_BITMONERO=$(du -h "$HOME/.bitmonero")
	else
		SIZE_BITMONERO="not found"
	fi

	log::debug "printing folder sizes"
	printf "${BWHITE}%s${BYELLOW}%s\n" \
		"monero-bash    | " "${SIZE_MONERO_BASH/$'\t'*}" \
		"Monero         | " "${SIZE_MONERO/$'\t'*}" \
		"P2Pool         | " "${SIZE_P2POOL/$'\t'*}" \
		"XMRig          | " "${SIZE_XMRIG/$'\t'*}" \
		"/.bitmonero/   | " "${SIZE_BITMONERO/$'\t'*}" \
		"/.monero-bash/ | " "${SIZE_DOT/$'\t'*}"
	return 0
}
