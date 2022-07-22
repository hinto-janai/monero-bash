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

# checks if package binary is found
# usage: $1 = package to search for
safety::package() {
	log::debug "starting safety::package"

	[[ $1 ]] || return 1
	struct::pkg "$1" || return 2

	# check if installed
	if [[ ${PKG[current_version]} ]]; then
		log::debug "${PKG[pretty]} (${PKG[current_version]}) is installed"
	else
		print::exit "${PKG[pretty]} is not installed"
	fi

	# check for binary
	case "${PKG[name]}" in
		*bash*)   [[ -e $PKG_MONERO_BASH/monero-bash ]] || print::exit "monero-bash not found, this error should be impossible!";;
		*monero*)
			[[ -e $PKG_MONERO/monerod ]]                || print::exit "monerod binary was not found!"
			[[ -e $PKG_MONERO/monero-wallet-cli ]]      || print::exit "monero-wallet-cli binary was not found!"
			;;
		*p2p*)    [[ -e $PKG_P2POOL/p2pool ]]           || print::exit "P2Pool binary was not found!";;
		*xmr*)    [[ -e $PKG_XMRIG/xmrig ]]             || print::exit "XMRig binary was not found!";;
	esac
	return 0
}
