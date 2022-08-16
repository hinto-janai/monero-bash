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

# install functions
install_Template()
{
	if [[ "$NAME_VER" != "" ]]; then
		$off; echo -n "$NAME_PRETTY ($NAME_VER) "
		$off; echo "is already installed"
	else
		local INSTALL="true"
		upgrade_"$NAME_FUNC"
	fi
}

install_MoneroBash()
{
	define_MoneroBash
	install_Template
}

install_Monero()
{
	define_Monero
	install_Template
}

install_XMRig()
{
	define_XMRig
	install_Template
}

install_P2Pool()
{
	define_P2Pool
	install_Template
}

install_All()
{
	[[ $MONERO_VER = "" ]]&& install_Monero
	[[ $XMRIG_VER = "" ]]&& install_XMRig
	[[ $P2POOL_VER = "" ]]&& install_P2Pool
}