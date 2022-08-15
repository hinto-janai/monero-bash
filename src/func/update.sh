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


# update functions

update_Template()
{
	version_Update
	if [[ "$NAME_VER" != "$NewVer" ]]; then
		$bwhite; echo -n "$NAME_SPACED"
		$bred; echo -n "$NAME_VER "
		$bwhite; echo -n "-> "
		$bgreen; echo "$NewVer"
		updateFound="true"
		sudo sed -i "s@.*"$NAME_CAPS"_OLD=.*@"$NAME_CAPS"_OLD=\"true\"@" "$state"
		PRODUCE_HASH_LIST &>/dev/null
	else
		sudo sed -i "s@.*"$NAME_CAPS"_OLD=.*@"$NAME_CAPS"_OLD=\"false\"@" "$state"
		PRODUCE_HASH_LIST &>/dev/null
		$bwhite; echo -n "$NAME_SPACED"
		$bgreen; echo "$NAME_VER"
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
	$bwhite; printf "%s\n\n" "### Fetching pkg meta-data ###"
	update_MoneroBash
	[[ $MONERO_VER != "" ]]&& update_Monero
	[[ $XMRIG_VER != "" ]]&& update_XMRig
	[[ $P2POOL_VER != "" ]]&& update_P2Pool
    if [[ $updateFound = "true" ]]; then
        echo
        $off; echo -n "Updates found, type: "
        $byellow; echo -n "[monero-bash upgrade] "
        $off; echo "to upgrade all"
        $off
		exit 0
	else
		$bgreen; printf "\n%s\n" "### All package up-to-date ###"
		$off; exit 1
    fi
}
