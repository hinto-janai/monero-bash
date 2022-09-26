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


# echo all the variable definitions
# after upgrading
#
verbose_Upgrade()
{
	printf "${BYELLOW}%s${OFF}%s\n" \
		"NAME_VER    | " "$NAME_VER" \
		"NAME_OLD    | " "$NAME_OLD" \
		"NAME_PRETTY | " "$NAME_PRETTY" \
		"NAME_FUNC   | " "$NAME_FUNC" \
		"NAME_CAPS   | " "$NAME_CAPS" \
		"SERVICE     | " "$SERVICE" \
		"DIRECTORY   | " "$DIRECTORY" \
		"API         | " "$API" \
	 	"HTML        | " "$HTML" \
		"AUTHOR      | " "$AUTHOR" \
		"PROJECT     | " "$PROJECT" \
		"STAR_PKG    | " "$STAR_PKG" \
		"DOT_PKG     | " "$DOT_PKG" \
		"SHA         | " "$SHA" \
		"SIG         | " "$SIG" \
	    "FINGERPRINT | " "$FINGERPRINT" \
		"VERIFY_GPG  | " "$VERIFY_GPG" \
		"NewVer      | " "$NewVer" \
		"LINK        | " "$LINK" \
		"GPG_PUB_KEY | " "$GPG_PUB_KEY" \
		"hashLink    | " "$hashLink" \
		"sigLink     | " "$sigLink" \
		"tmp         | " "$tmp" \
		"tmpHash     | " "$tmpHash" \
		"tmpSig      | " "$tmpSig" \
		"hashFile    | " "$hashFile" \
		"sigFile     | " "$sigFile" \
		"folderName  | " "$folderName" \
		"tarFile     | " "$tarFile" \
		"HASH        | " "$HASH" \
		"LOCAL_HASH  | " "$LOCAL_HASH"
	local IFS=$'\n'
	for i in $hashSTDOUT; do
		printf "${BPURPLE}%s${OFF}%s\n" "hashSTDOUT  | " "$i"
	done
	for i in $gpgSTDOUT; do
		printf "${BBLUE}%s${OFF}%s\n" "gpgSTDOUT   | " "$i"
	done
}
