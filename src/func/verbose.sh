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


# echo all the variable definitions
# after upgrading
#
verbose_Upgrade()
{
	BWHITE; echo -n "NAME_VER: " ;OFF; echo "$NAME_VER"
	BWHITE; echo -n "NAME_OLD: " ;OFF; echo "$NAME_OLD"
	BWHITE; echo -n "NAME_PRETTY: " ;OFF; echo "$NAME_PRETTY"
	BWHITE; echo -n "NAME_FUNC: " ;OFF; echo "$NAME_FUNC"
	BWHITE; echo -n "NAME_CAPS: " ;OFF; echo "$NAME_CAPS"
	BWHITE; echo -n "SERVICE: " ;OFF; echo "$SERVICE"
	BWHITE; echo -n "DIRECTORY: " ;OFF; echo "$DIRECTORY"
	BWHITE; echo -n "API: " ;OFF; echo "$API"
 	BWHITE; echo -n "HTML: " ;OFF; echo "$HTML"
	BWHITE; echo -n "AUTHOR: " ;OFF; echo "$AUTHOR"
	BWHITE; echo -n "PROJECT: " ;OFF; echo "$PROJECT"
	BWHITE; echo -n "STAR_PKG: " ;OFF; echo "$STAR_PKG"
	BWHITE; echo -n "DOT_PKG: " ;OFF; echo "$DOT_PKG"
	BWHITE; echo -n "SHA: " ;OFF; echo "$SHA"
	BWHITE; echo -n "SIG: " ;OFF; echo "$SIG"
    BWHITE; echo -n "FINGERPRINT: " ;OFF; echo "$FINGERPRINT"
	BWHITE; echo -n "VERIFY_GPG: " ;OFF; echo "$VERIFY_GPG"
	BWHITE; echo -n "NewVer: " ;OFF; echo "$NewVer"
	BWHITE; echo -n "LINK: " ;OFF; echo "$LINK"
	BWHITE; echo -n "GPG_PUB_KEY: " ;OFF; echo "$GPG_PUB_KEY"
	BWHITE; echo -n "hashLink: " ;OFF; echo "$hashLink"
	BWHITE; echo -n "sigLink: " ;OFF; echo "$sigLink"
	BWHITE; echo -n "tmp: " ;OFF; echo "$tmp"
	BWHITE; echo -n "tmpHash: " ;OFF; echo "$tmpHash"
	BWHITE; echo -n "tmpSig: " ;OFF; echo "$tmpSig"
	BWHITE; echo -n "hashFile: " ;OFF; echo "$hashFile"
	BWHITE; echo -n "sigFile: " ;OFF; echo "$sigFile"
	BWHITE; echo -n "folderName: " ;OFF; echo "$folderName"
	BWHITE; echo -n "tarFile: " ;BBLUE; echo "$tarFile"
	BWHITE; echo -n "HASH: " ;BBLUE; echo "$HASH"
	BWHITE; echo -n "LOCAL_HASH: " ;BRED; echo "$LOCAL_HASH"
	BWHITE; echo "hashSTDOUT: " ;OFF
	export GREP_COLOR="1;34"
	echo "$hashSTDOUT" | grep --color -z "$HASH\|$tarFile"
	BWHITE; echo "gpgSTDOUT: " ;OFF; echo "$gpgSTDOUT"
}
