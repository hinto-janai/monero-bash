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

# messages for when hash/gpg is incorrect

compromised_Hash()
{
    $bwhite; echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
    $bred; echo "  WARNING: HASH ERROR!"
    $bred; echo "  [$NAME_PRETTY] hash did not match!"
    $bred; echo "  [$AUTHOR] might be compromised"
    $bred; echo  "  (or more likely, there was an error)"
    $bwhite; echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
	$bwhite; echo -n "ONLINE HASH: " ;$bblue; echo "$HASH"
	$bwhite; echo -n "LOCAL HASH: " ;$bred; echo "$LOCAL_HASH"
	$bred; echo "EXITING FOR SAFTEY..."
	[[ $VERBOSE = "true" ]]&& verbose_Upgrade
	exit 1
}

compromised_GPG()
{
    $bwhite; echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
    $bblue; echo "  WARNING: GPG SIGNATURE ERROR!"
    $bblue; echo "  [$NAME_PRETTY] GPG Signature did not match!"
    $bblue; echo "  [$GPG_OWNER] might be compromised"
    $bblue; echo  "  (or more likely, there was an error)"
    $bwhite; echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
	$bwhite; echo -n "ONLINE HASH: " ;$bblue; echo "$HASH"
	$bwhite; echo -n "LOCAL HASH: " ;$bred; echo "$LOCAL_HASH"
	$bwhite; echo "gpgSTDOUT: " ;$off; echo "$gpgSTDOUT"
	$bred; echo "EXITING FOR SAFTEY..."
	[[ $VERBOSE = "true" ]]&& verbose_Upgrade
	exit 1
}
