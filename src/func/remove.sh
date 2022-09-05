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

# remove functions

remove_Template()
{
	if [[ "$NAME_VER" = "" ]]; then
		OFF; echo -n "$NAME_PRETTY: "
		IRED; echo "is not installed"
	else
		# sudo, trap
		prompt_Sudo;error_Sudo
		safety_HashList
		trap "" 1 2 3 6 15

		# removal
		print_RedHash "Removing [$NAME_PRETTY]"
		printf "${BWHITE}%s${OFF}\n" "${DIRECTORY}..."
		sudo rm -rf "$DIRECTORY"
		printf "${BWHITE}%s${OFF}\n" "${SERVICE}..."
		sudo rm "$sysd/$SERVICE"

		# updating state file
		printf "${BWHITE}%s${OFF}\n" "Updating local state"
		sudo sed -i "s@.*"$NAME_CAPS"_VER=.*@"$NAME_CAPS"_VER=\"\"@" "$state"
		sudo sed -i "s@.*"$NAME_CAPS"_OLD=.*@"$NAME_CAPS"_OLD=\"true\"@" "$state"
		PRODUCE_HASH_LIST
		printf "${BRED}%s${OFF}\n" "<######> Removed [$NAME_PRETTY]"
	fi
}

remove_Monero()
{
	define_Monero
	remove_Template
}

remove_MoneroBash()
{
	IWHITE; echo -n "type: "
	BRED; echo -n "monero-bash uninstall "
	IWHITE; echo "to remove monero-bash"
}

remove_XMRig()
{
	define_XMRig
	remove_Template
}

remove_P2Pool()
{
	define_P2Pool
	remove_Template
}

remove_All()
{
	remove_Monero
	remove_XMRig
	remove_P2Pool
}
