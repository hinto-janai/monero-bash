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

# Missing "x" Functions

missing_Template()
{
	[[ ! -e "$DIR" ]]&& print_Error_Exit "$THING missing!"
}

missing_Monero()
{
	local DIR="$binMonero/monerod"
	local THING="monerod"
	missing_Template
}

missing_MoneroCLI()
{
	local DIR="$binMonero/monero-wallet-cli"
	local THING="monero-wallet-cli"
	missing_Template
}

missing_BinMonero()
{
	local DIR="$binMonero"
	local THING="$binMonero"
	missing_Template
}

missing_P2Pool()
{
	local DIR="$binP2Pool/p2pool"
	local THING="P2Pool"
	missing_Template
}

missing_XMRig()
{
	local DIR="$binXMRig/xmrig"
	local THING="XMRig"
	missing_Template
}

missing_Wallets()
{
	if [[ ! -d "$wallets" ]]; then
		print_Warn "$wallets missing!"
		echo "Creating wallet folder..."
		mkdir "$wallets"
	fi
}

missing_config_Folder()
{
	if [[ ! -d "$config" ]]; then
		print_Warn "$config missing!"
		echo "Creating default config folder..."
		build_Config
		source "$config/monero-bash.conf" &>/dev/null
		[[ -e "$config/p2pool.conf" ]] && source "$config/p2pool.conf" &>/dev/null
	fi
}

missing_config_Template()
{
	if [[ ! -f "$config/$conf" ]]; then
		print_Warn "[${conf}] missing!"
		echo "Creating default [${conf}]..."
		cp "$installDirectory/config/$conf" "$config/$conf"
	fi
}

missing_config_Monero()
{
	local conf="monerod.conf"
	missing_config_Template
}

missing_config_Wallet()
{
	local conf="monero-wallet-cli.conf"
	missing_config_Template
}


missing_config_MoneroBash()
{
	local conf="monero-bash.conf"
	missing_config_Template
	source "$config/monero-bash.conf" &>/dev/null
	[[ -e "$config/p2pool.conf" ]] && source "$config/p2pool.conf" &>/dev/null
}


missing_config_XMRig()
{
	local conf="xmrig.json"
	missing_config_Template
}

missing_config_P2Pool()
{
	local conf="p2pool.conf"
	missing_config_Template
	source "$config/monero-bash.conf" &>/dev/null
	[[ -e "$config/p2pool.conf" ]] && source "$config/p2pool.conf" &>/dev/null
}

missing_config_All()
{
	missing_config_MoneroBash
	[[ $MONERO_VER != "" ]]&& missing_config_Monero && missing_config_Wallet
	[[ $XMRIG_VER != "" ]]&& missing_config_XMRig
	[[ $P2POOL_VER != "" ]]&& missing_config_P2Pool
}

missing_systemd_Template()
{
	# if pkg is installed but no service file:
	if [[ "$NAME_VER" != "" && ! -f $sysd/$SERVICE ]]; then
		print_Warn "${SERVICE} missing!"
		echo "Creating default..."
		systemd_"$NAME_FUNC"
	fi
}

missing_systemd_Monero()
{
	define_Monero
	missing_systemd_Template
}

missing_systemd_XMRig()
{
	define_XMRig
	missing_systemd_Template
}

missing_systemd_P2Pool()
{
	define_P2Pool
	missing_systemd_Template
}

missing_systemd_All()
{
	missing_systemd_Monero
	missing_systemd_XMRig
	missing_systemd_P2Pool
}
