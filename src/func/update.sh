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
#
# Parts of this project are licensed under GPLv2:
# Copyright (c) ????-2022, Tamas Szerb <toma@rulez.org>
# Copyright (c) 2008-2022, Robert Hogan <robert@roberthogan.net>
# Copyright (c) 2008-2022, David Goulet <dgoulet@ev0ke.net>
# Copyright (c) 2008-2022, Alex Xu (Hello71) <alex_y_xu@yahoo.ca>


# update functions

update_Template()
{
	version_Update
	if [[ "$NAME_VER" != "$NewVer" ]]; then
		BWHITE; echo -n "$NAME_SPACED"
		BRED; echo -n "$NAME_VER "
		BWHITE; echo -n "-> "
		BGREEN; echo "$NewVer"
		updateFound="true"
		sudo sed -i "s@.*"$NAME_CAPS"_OLD=.*@"$NAME_CAPS"_OLD=\"true\"@" "$state"
		PRODUCE_HASH_LIST &>/dev/null
	else
		sudo sed -i "s@.*"$NAME_CAPS"_OLD=.*@"$NAME_CAPS"_OLD=\"false\"@" "$state"
		PRODUCE_HASH_LIST &>/dev/null
		BWHITE; echo -n "$NAME_SPACED"
		BGREEN; echo "$NAME_VER"
	fi
}

update_Monero()
{
	define_Monero
	local NAME_SPACED="Monero      | "
	update_Template
}

update_MoneroBash()
{
	define_MoneroBash
	local NAME_SPACED="monero-bash | "
	update_Template
}

update_XMRig()
{
	define_XMRig
	local NAME_SPACED="XMRig       | "
	update_Template
}

update_P2Pool()
{
	define_P2Pool
	local NAME_SPACED="P2Pool      | "
	update_Template
}

update_All()
{
	prompt_Sudo
	error_Sudo
	[[ $USE_TOR = true ]] && torsocks_init
	[[ $FAKE_HTTP_HEADERS = true ]] && header_Random
	printf "${BBLUE}${UBLUE}%s\n${OFF}" "<###> Fetching package metadata <###>"
	update_MoneroBash
	[[ $MONERO_VER != "" ]]&& update_Monero
	[[ $XMRIG_VER != "" ]]&& update_XMRig
	[[ $P2POOL_VER != "" ]]&& update_P2Pool
    if [[ $updateFound = "true" ]]; then
        echo
        OFF; echo -n "Updates found, type: "
        BYELLOW; echo -n "[monero-bash upgrade] "
        OFF; echo "to upgrade all"
        OFF
		return 0
	else
		printf "\n${BGREEN}%s${OFF}\n" "<####> All packages up-to-date <####>"
		return 1
    fi
}
