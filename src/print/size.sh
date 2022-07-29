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
	log::debug "starting"
	log::debug "getting folder sizes"

	local SIZE_MONERO_BASH SIZE_MONERO SIZE_P2POOL SIZE_XMRIG SIZE_BITMONERO SIZE_DOT || return 1
	SIZE_MONERO_BASH=$(du -h "$PKG_MONERO_BASH")
	[[ $MONERO_VER ]] && SIZE_MONERO=$(du -h "$PKG_MONERO") || SIZE_MONERO=
	[[ $P2POOL_VER ]] && SIZE_P2POOL=$(du -h "$PKG_P2POOL") || SIZE_P2POOL=
	[[ $XMRIG_VER ]]  && SIZE_XMRIG=$(du -h "$PKG_XMRIG") || SIZE_XMRIG=
	SIZE_DOT=$(du -h "$DOT")
	[[ -d "$DOT/.bitmonero" ]] && SIZE_BITMONERO=$(du -h "$DOT/.bitmonero") || SIZE_BITMONERO=

	log::debug "printing folder sizes"
	printf "${BWHITE}%s${BYELLOW}%s${OFF}\n" "monero-bash    | " "${SIZE_MONERO_BASH/$'\t'*}"
	[[ $SIZE_MONERO ]]    && printf "${BWHITE}%s${BYELLOW}%s${OFF}\n" "Monero         | " "${SIZE_MONERO/$'\t'*}"
	[[ $SIZE_P2POOL ]]    && printf "${BWHITE}%s${BYELLOW}%s${OFF}\n" "P2Pool         | " "${SIZE_P2POOL/$'\t'*}"
	[[ $SIZE_XMRIG ]]     && printf "${BWHITE}%s${BYELLOW}%s${OFF}\n" "XMRig          | " "${SIZE_XMRIG/$'\t'*}"
	[[ $SIZE_BITMONERO ]] && printf "${BWHITE}%s${BYELLOW}%s${OFF}\n" "/.bitmonero/   | " "${SIZE_BITMONERO/$'\t'*}"
	printf "${BWHITE}%s${BYELLOW}%s${OFF}\n" "/.monero-bash/ | " "${SIZE_DOT/$'\t'*}"
}
