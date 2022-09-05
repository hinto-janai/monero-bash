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

# gpg functions for:
# 	-importing gpgs keys
#	-checking LOCAL/ONLINE diff
#	-overwriting LOCAL keys with ONLINE

gpg_import_Template()
{
	local LOCAL="$(cat "$installDirectory/gpg/${GPG_OWNER}.asc")"
	if [[ $USE_TOR = true ]]; then
		local ONLINE="$(torsocks_func wget "${WGET_HTTP_HEADERS[@]}" -e robots=off -qO- "$GPG_PUB_KEY")"
	else
		local ONLINE="$(wget "${WGET_HTTP_HEADERS[@]}" -e robots=off -qO- "$GPG_PUB_KEY")"
	fi
	if [[ "$LOCAL" = "$ONLINE" ]]; then
		gpg --import "$installDirectory/gpg/${GPG_OWNER}.asc"
	else
		gpg_Diff
	fi
}

gpg_import_Monero()
{
	define_Monero
	gpg_import_Template
}

gpg_import_MoneroBash()
{
	define_MoneroBash
	gpg_import_Template
}

gpg_import_XMRig()
{
	define_XMRig
	gpg_import_Template
}

gpg_import_P2Pool()
{
	define_P2Pool
	gpg_import_Template
}
gpg_import_All()
{
	gpg_import_Monero
	gpg_import_MoneroBash
	gpg_import_XMRig
	gpg_import_P2Pool
}

gpg_Diff()
{
	BWHITE; echo -n "The LOCAL and ONLINE gpg keys of "
	BRED; echo -n "$GPG_OWNER "
	BWHITE; echo "are different!" ;OFF
	BBLUE; echo -n "LOCAL: "
	OFF; echo "$installDirectory/gpg/${GPG_OWNER}.asc"
	BGREEN; echo -n "ONLINE: "
	OFF; echo "$GPG_PUB_KEY"
	while true ;do
		BWHITE; echo -n "What to do? [show / pick / skip] " ;OFF
		read OPTION
		case $OPTION in
			show)
				BBLUE; echo "LOCAL KEY:"
				OFF; echo "$LOCAL"
				BGREEN; echo "ONLINE KEY:"
				OFF; echo "$ONLINE"
				;;
			pick)
				while true; do
					BWHITE; echo -n "Which key to pick? [local / online] " ;OFF
					read KEYPICK
					case $KEYPICK in
						local) gpg --import "$installDirectory/gpg/${GPG_OWNER}.asc" && break ;;
						online) gpg_Overwrite && break ;;
						*) print_Error "Invalid option"
					esac
				done
				break
				;;
			skip)
				BWHITE; echo "Skipping..."
				echo
				break
				;;
			*)
				error_Continue "Invalid option"
				;;
		esac
	done
}

gpg_Overwrite()
{
	prompt_Sudo
	error_Sudo
	safety_HashList
	BWHITE; echo "Overwriting LOCAL keys..." ;OFF
	trap "trap_Hash" 1 2 3 6 15
	if [[ $USE_TOR = true ]]; then
		torsocks_func wget "${WGET_HTTP_HEADERS[@]}" -e robots=off -q -O "$installDirectory/gpg/${GPG_OWNER}.asc" "$GPG_PUB_KEY"
	else
		wget "${WGET_HTTP_HEADERS[@]}" -e robots=off -q -O "$installDirectory/gpg/${GPG_OWNER}.asc" "$GPG_PUB_KEY"
	fi
	code_Wget
	PRODUCE_HASH_LIST
	local LOCAL="$(cat "$installDirectory/gpg/${GPG_OWNER}.asc")"
	gpg_import_Template
}
