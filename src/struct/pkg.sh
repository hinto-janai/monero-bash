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

# structures for packages
struct::pkg() {
	log::debug "defining: $1"
	declare -Ag PKG

	# pick package with $1
	[[ $# != 1 ]] && return 1
	case "$1" in
	monero)
		PKG[name]="monero"
		PKG[short]="monero"
		PKG[pretty]="Monero"
		PKG[var]="MONERO"
		PKG[author]="monero-project"
		PKG[gpg_owner]="binaryFate"
		PKG[service]="monero-bash-monerod.service"
		PKG[process]="monerod"
		PKG[directory]="$PACKAGES/monero"
		PKG[regex]="monero-linux-x64.*"
		PKG[hash]="hashes.txt"
		PKG[sig]="${PKG[hash]}"
		PKG[gpg_pub_key]="https://raw.githubusercontent.com/monero-project/monero/master/utils/gpg_keys/binaryfate.asc"
		PKG[fingerprint]="81AC591FE9C4B65C5806AFC3F0AF4D462A0BDF92"
		PKG[current_version]="$MONERO_VER"
		PKG[old]="$MONERO_OLD"
		PKG[conf]="$CONFIG_MONEROD"
		PKG[conf_name]="monerod.conf"
		;;
	*bash*)
		PKG[name]="monero-bash"
		PKG[short]="bash"
		PKG[pretty]="monero-bash"
		PKG[var]="MONERO_BASH"
		PKG[author]="hinto-janaiyo"
		PKG[gpg_owner]="hinto-janaiyo"
		PKG[service]=
		PKG[process]=
		PKG[directory]="$PACKAGES/monero-bash"
		PKG[regex]="monero-bash-v.*"
		PKG[hash]="SHA256SUM"
		PKG[sig]="${PKG[hash]}"
		PKG[gpg_pub_key]="https://github.com/hinto-janaiyo/monero-bash/blob/main/pgp/hinto-janaiyo.asc"
		PKG[fingerprint]="21958EE945980282FCB849C8D7483F6CA27D1B1D"
		PKG[current_version]="$MONERO_BASH_VER"
		PKG[old]="$MONERO_BASH_OLD"
		PKG[conf]="$CONFIG_MONERO_BASH"
		PKG[conf_name]="monero-bash.conf"
		;;
	*p2p*)
		PKG[name]="p2pool"
		PKG[short]="p2pool"
		PKG[pretty]="P2Pool"
		PKG[var]="P2POOL"
		PKG[author]="SChernykh"
		PKG[gpg_owner]="SChernykh"
		PKG[service]="monero-bash-p2pool.service"
		PKG[process]="p2pool"
		PKG[directory]="$PACKAGES/p2pool"
		PKG[regex]="p2pool.*linux-x64.tar.*"
		PKG[hash]="sha256sums.txt.asc"
		PKG[sig]="${PKG[hash]}"
		PKG[gpg_pub_key]="https://raw.githubusercontent.com/monero-project/gitian.sigs/master/gitian-pubkeys/SChernykh.asc"
		PKG[fingerprint]="1FCAAB4D3DC3310D16CBD508C47F82B54DA87ADF"
		PKG[current_version]="$P2POOL_VER"
		PKG[old]="$P2POOL_OLD"
		PKG[conf]="$CONFIG_P2POOL"
		PKG[conf_name]="p2pool.conf"
		;;
	*xmr*)
		PKG[name]="xmrig"
		PKG[short]="xmrig"
		PKG[pretty]="XMRig"
		PKG[var]="XMRIG"
		PKG[author]="xmrig"
		PKG[gpg_owner]="XMRig"
		PKG[service]="monero-bash-xmrig.service"
		PKG[process]="xmrig"
		PKG[directory]="$PACKAGES/xmrig"
		PKG[regex]="xmrig.*linux-static-x64.tar.*"
		PKG[hash]="SHA256SUMS"
		PKG[sig]="${PKG[hash]}.sig"
		PKG[gpg_pub_key]="https://raw.githubusercontent.com/xmrig/xmrig/master/doc/gpg_keys/xmrig.asc"
		PKG[fingerprint]="9AC4CEA8E66E35A5C7CDDC1B446A53638BE94409"
		PKG[current_version]="$XMRIG_VER"
		PKG[old]="$XMRIG_OLD"
		PKG[conf]="$CONFIG_XMRIG"
		PKG[conf_name]="xmrig.json"
		;;
	esac

	# inferred variables
	PKG[link_api]="https://api.github.com/repos/${PKG[author]}/${PKG[name]}/releases/latest"
}