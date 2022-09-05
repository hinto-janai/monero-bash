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
# Copyright (c) 2011-2022, Dominic Tarr
# Copyright (c) ????-2022, Tamas Szerb <toma@rulez.org>
# Copyright (c) 2008-2022, Robert Hogan <robert@roberthogan.net>
# Copyright (c) 2008-2022, David Goulet <dgoulet@ev0ke.net>
# Copyright (c) 2008-2022, Alex Xu (Hello71) <alex_y_xu@yahoo.ca>

# defines variables of packages
define_Monero()
{
	NAME_VER="$MONERO_VER"
	NAME_OLD="$MONERO_OLD"
	NAME_PRETTY="Monero"
	NAME_FUNC="Monero"
	SERVICE="monero-bash-monerod.service"
	PROCESS="monerod"
	DIRECTORY="$binMonero"
	NAME_CAPS="MONERO"
	FOLDER="monero"
	AUTHOR="monero-project"
	PROJECT="monero"
	STAR_PKG="monero-linux-x64*"
	DOT_PKG="monero-linux-x64.*"
	SHA="hashes.txt"
	SIG="$SHA"
	GPG_OWNER="binaryfate"
	GPG_PUB_KEY="https://raw.githubusercontent.com/monero-project/monero/master/utils/gpg_keys/binaryfate.asc"
	FINGERPRINT="81AC591FE9C4B65C5806AFC3F0AF4D462A0BDF92"
}

define_MoneroBash()
{
	NAME_VER="$MONERO_BASH_VER"
	NAME_OLD="$MONERO_BASH_OLD"
	NAME_PRETTY="monero-bash"
	NAME_FUNC="MoneroBash"
	SERVICE=""
	PROCESS=""
	DIRECTORY="$installDirectory"
	NAME_CAPS="MONERO_BASH"
	AUTHOR="hinto-janaiyo"
	PROJECT="monero-bash"
	STAR_PKG="monero-bash-v*"
	DOT_PKG="monero-bash-v.*"
	SHA="SHA256SUM"
	SIG="$SHA"
	GPG_OWNER="hinto-janaiyo"
	GPG_PUB_KEY="https://raw.githubusercontent.com/hinto-janaiyo/monero-bash/master/gpg/hinto-janaiyo.asc"
	FINGERPRINT="21958EE945980282FCB849C8D7483F6CA27D1B1D"
}

define_XMRig()
{
	NAME_VER="$XMRIG_VER"
	NAME_OLD="$XMRIG_OLD"
	NAME_PRETTY="XMRig"
	NAME_FUNC="XMRig"
	SERVICE="monero-bash-xmrig.service"
	PROCESS="xmrig"
	DIRECTORY="$binXMRig"
	NAME_CAPS="XMRIG"
	FOLDER="xmrig"
	AUTHOR="xmrig"
	PROJECT="xmrig"
	STAR_PKG="xmrig*linux-static-x64*"
	DOT_PKG="xmrig.*linux-static-x64.*"
	SHA="SHA256SUMS"
	SIG="${SHA}.sig"
	GPG_OWNER="xmrig"
	GPG_PUB_KEY="https://raw.githubusercontent.com/xmrig/xmrig/master/doc/gpg_keys/xmrig.asc"
	FINGERPRINT="9AC4CEA8E66E35A5C7CDDC1B446A53638BE94409"
}

define_P2Pool()
{
	NAME_VER="$P2POOL_VER"
	NAME_OLD="$P2POOL_OLD"
	NAME_PRETTY="P2Pool"
	NAME_FUNC="P2Pool"
	SERVICE="monero-bash-p2pool.service"
	PROCESS="p2pool"
	DIRECTORY="$binP2Pool"
	NAME_CAPS="P2POOL"
	FOLDER="p2pool"
	AUTHOR="SChernykh"
	PROJECT="p2pool"
	STAR_PKG="p2pool*linux-x64*"
	DOT_PKG="p2pool.*linux-x64.*"
	SHA="sha256sums.txt.asc"
	SIG="$SHA"
	GPG_OWNER="SChernykh"
	GPG_PUB_KEY="https://raw.githubusercontent.com/monero-project/gitian.sigs/master/gitian-pubkeys/SChernykh.asc"
	FINGERPRINT="1FCAAB4D3DC3310D16CBD508C47F82B54DA87ADF"
}
