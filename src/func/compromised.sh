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

# messages for when hash/gpg is incorrect

compromised_Hash()
{
    BWHITE; echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
    BRED; echo "  WARNING: HASH ERROR!"
    BRED; echo "  [$NAME_PRETTY] hash did not match!"
    BRED; echo "  [$AUTHOR] might be compromised"
    BRED; echo  "  (or more likely, there was an error)"
    BWHITE; echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
	BWHITE; echo -n "ONLINE HASH: " ;BBLUE; echo "$HASH"
	BWHITE; echo -n "LOCAL HASH: " ;BRED; echo "$LOCAL_HASH"
	BRED; echo "EXITING FOR SAFTEY..."
	[[ $VERBOSE = "true" ]]&& verbose_Upgrade
	exit 1
}

compromised_GPG()
{
    BWHITE; echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
    BBLUE; echo "  WARNING: GPG SIGNATURE ERROR!"
    BBLUE; echo "  [$NAME_PRETTY] GPG Signature did not match!"
    BBLUE; echo "  [$GPG_OWNER] might be compromised"
    BBLUE; echo  "  (or more likely, there was an error)"
    BWHITE; echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
	BWHITE; echo -n "ONLINE HASH: " ;BBLUE; echo "$HASH"
	BWHITE; echo -n "LOCAL HASH: " ;BRED; echo "$LOCAL_HASH"
	BWHITE; echo "gpgSTDOUT: " ;OFF; echo "$gpgSTDOUT"
	BRED; echo "EXITING FOR SAFTEY..."
	[[ $VERBOSE = "true" ]]&& verbose_Upgrade
	exit 1
}
