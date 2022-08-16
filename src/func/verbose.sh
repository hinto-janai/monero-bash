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


# echo all the variable definitions
# after upgrading
#
verbose_Upgrade()
{
	$bwhite; echo -n "NAME_VER: " ;$off; echo "$NAME_VER"
	$bwhite; echo -n "NAME_OLD: " ;$off; echo "$NAME_OLD"
	$bwhite; echo -n "NAME_PRETTY: " ;$off; echo "$NAME_PRETTY"
	$bwhite; echo -n "NAME_FUNC: " ;$off; echo "$NAME_FUNC"
	$bwhite; echo -n "NAME_CAPS: " ;$off; echo "$NAME_CAPS"
	$bwhite; echo -n "SERVICE: " ;$off; echo "$SERVICE"
	$bwhite; echo -n "DIRECTORY: " ;$off; echo "$DIRECTORY"
	$bwhite; echo -n "API: " ;$off; echo "$API"
 	$bwhite; echo -n "HTML: " ;$off; echo "$HTML"
	$bwhite; echo -n "AUTHOR: " ;$off; echo "$AUTHOR"
	$bwhite; echo -n "PROJECT: " ;$off; echo "$PROJECT"
	$bwhite; echo -n "STAR_PKG: " ;$off; echo "$STAR_PKG"
	$bwhite; echo -n "DOT_PKG: " ;$off; echo "$DOT_PKG"
	$bwhite; echo -n "SHA: " ;$off; echo "$SHA"
	$bwhite; echo -n "SIG: " ;$off; echo "$SIG"
    $bwhite; echo -n "FINGERPRINT: " ;$off; echo "$FINGERPRINT"
	$bwhite; echo -n "VERIFY_GPG: " ;$off; echo "$VERIFY_GPG"
	$bwhite; echo -n "NewVer: " ;$off; echo "$NewVer"
	$bwhite; echo -n "LINK: " ;$off; echo "$LINK"
	$bwhite; echo -n "GPG_PUB_KEY: " ;$off; echo "$GPG_PUB_KEY"
	$bwhite; echo -n "hashLink: " ;$off; echo "$hashLink"
	$bwhite; echo -n "sigLink: " ;$off; echo "$sigLink"
	$bwhite; echo -n "tmp: " ;$off; echo "$tmp"
	$bwhite; echo -n "tmpHash: " ;$off; echo "$tmpHash"
	$bwhite; echo -n "tmpSig: " ;$off; echo "$tmpSig"
	$bwhite; echo -n "hashFile: " ;$off; echo "$hashFile"
	$bwhite; echo -n "sigFile: " ;$off; echo "$sigFile"
	$bwhite; echo -n "folderName: " ;$off; echo "$folderName"
	$bwhite; echo -n "tarFile: " ;$bblue; echo "$tarFile"
	$bwhite; echo -n "HASH: " ;$bblue; echo "$HASH"
	$bwhite; echo -n "LOCAL_HASH: " ;$bred; echo "$LOCAL_HASH"
	$bwhite; echo "hashSTDOUT: " ;$off
	export GREP_COLOR="1;34"
	echo "$hashSTDOUT" | grep --color -z "$HASH\|$tarFile"
	$bwhite; echo "gpgSTDOUT: " ;$off; echo "$gpgSTDOUT"
}