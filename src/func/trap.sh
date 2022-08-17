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


# trap that handles exits (and cleanup)
trap_Template()
{
	trap "" 1 2 3 6 15
	[[ $VERBOSE = "true" ]]&& verbose_Upgrade
}

# continue current operation until finished and revert (ONLY FOR UPGRADE)
trap_No()
{
	trap_Template
	trapSet="true"
	error_Trap "LETTING DATA TRANSFER FINISH TO PREVENT CORRUPTION"
	exit
}

# does everything POST install (rm temp files, state, hash)
trap_Post()
{
	trap_Template
	error_Trap "WRITING TO STATE BEFORE EXITING"
	version_Template
	sudo -u "$USER" sed -i "s@.*"$NAME_CAPS"_VER=.*@"$NAME_CAPS"_VER=\""$NewVer"\"@" "$state"
	sudo -u "$USER" sed -i "s@.*"$NAME_CAPS"_OLD=.*@"$NAME_CAPS"_OLD=\"false\"@" "$state"
	[[ "$INSTALL" = "true" ]]&& systemd_"$NAME_FUNC"
	PRODUCE_HASH_LIST
	sudo chown -R $USER "$installDirectory"
	[[ -d "$old" ]]&& sudo rm -rf "$old"
	tmp_Del
	exit
}

# delete tmp folder
trap_Tmp()
{
	trap_Template
	error_Trap "CLEANING TEMP FILES"
	tmp_Del
	exit
}

# revert monero-bash upgrades
trap_MoneroBash()
{
	trap_Template
	error_Trap "RESTORING OLD MONERO-BASH"
	sudo -u "$USER" mv -f "$old/monero-bash" "$installDirectory"
	sudo -u "$USER" mv -fr "$old/src" "$installDirectory"
	sudo -u "$USER" mv -fr "$old/config" "$installDirectory"
	sudo -u "$USER" mv -fr "$old/gpg" "$installDirectory"
	sudo -u "$USER" mv -f "$old/src/txt/state" "$state"
	sudo -u "$USER" cp -fr "$old/src/mini" "$installDirectory/src/"
	tmp_Del
	exit
}

# delete old folder
trap_Old()
{
	trap_Template
	error_Trap "CLEANING OLD FOLDER"
	[[ -d "$old" ]]&& rm -rf "$old"
	tmp_Del
	exit
}

# recreate hash list
trap_Hash()
{
	trap_Template
	error_Trap "RE-PRODUCING HASHLIST"
	PRODUCE_HASH_LIST
	exit
}
