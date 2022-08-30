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


# order of operations:
# 1. upgrade_Pre
# 2. Download, Verify, Extract, Replace
# 3. Edit the local state file
# 4. Recreate the local hashlist
# 5. upgrade_Post
#
# there are messages/checks mixed in between
# all the steps, which makes it a bit confusing.
# to add to the un-readability, monero-bash updating itself
# is a special case, so there is also an if/then that handles that
#
# other than that, the functions that make up "upgrade_Template"
# should be self-evident

upgrade_Pre()
{
	# v1 END OF LIFE FOR MONERO-BASH
	[[ $NAME_PRETTY = monero-bash ]] && ___END___OF___LIFE___

	# CHECK IF ALREADY INSTALLED/UP TO DATE
	if [[ -z $NAME_VER && $INSTALL != true ]]; then
		OFF; echo -n "$NAME_PRETTY: "
		IRED; echo "is not installed"
	elif [[ $NAME_OLD != true && $FORCE_UPGRADE != true ]]; then
		OFF; echo -n "$NAME_PRETTY: "
		BGREEN; echo "up to date" ;OFF
	else

		# ELSE, START UPGRADE
		prompt_Sudo ; error_Sudo
		echo ; safety_HashList
		trap "trap_Tmp" 1 2 3 6
		tmp_Create ; error_Exit "Could not create tmp folder"
		upgrade_Template
	fi
}

upgrade_Template()
{
	# DOWNLOAD
	print_BlueHash "Downloading [$NAME_PRETTY]"
	download_Template

	# VERIFY
	print_YellowHash "Verifying"
	verify_Template

	# EXTRACT
	if [[ $INSTALL = true ]]; then
		print_PurpleHash "Installing"
	else
		print_PurpleHash "Upgrading"
	fi
	tar -xf "$tmp/$tarFile" -C "$tmp"
	code_Tar
	OFF; echo -n "[Extract] "
	IGREEN; echo "OK" ;OFF
	rm -f "$tmp/$tarFile"
	error_Exit "rm - error"
	OFF; echo -n "[Cleanup] "
	IGREEN; echo "OK" ;OFF

	# TEMP FOLDER FOR OLD PACKAGE
	folderName="$(ls $tmp)"
	if [[ -d $old ]]; then
		sudo -u "$USER" rm -rf "$old"
		error_Exit "Could not remove old folder"
	fi

	# SAFETY CHECKS
	[[ -z $folderName || -z $tmp ]] && echo "EMPTY TMP VARIABLE, EXITING FOR SAFETY" && exit 1
	mkdir -p "$old"

	# INSTALL FOR MONERO_BASH
	if [[ $NAME_CAPS = MONERO_BASH ]]; then
		trap "trap_Old" 1 2 3 6 15
		sudo -u "$USER" cp "$installDirectory/monero-bash" "$old"
		sudo -u "$USER" cp -fr "$installDirectory/src" "$old"
		sudo -u "$USER" cp -fr "$installDirectory/config" "$old"
		sudo -u "$USER" cp -fr "$installDirectory/gpg" "$old"
		trap "trap_MoneroBash" 1 2 3 6 15
		sudo -u "$USER" cp -fr "$tmp/$folderName/monero-bash" "$installDirectory"
		sudo -u "$USER" cp -fr "$tmp/$folderName/src" "$installDirectory"
		sudo -u "$USER" cp -fr "$tmp/$folderName/config" "$installDirectory"
		sudo -u "$USER" cp -fr "$tmp/$folderName/gpg" "$installDirectory"
		sudo -u "$USER" cp -fr "$old/src/txt/state" "$state"
		sudo -u "$USER" cp -fr "$old/src/api" "$installDirectory/src/"
		[[ -d "$old/src/mini" ]] && sudo -u "$USER" cp -fr "$old/src/mini" "$installDirectory/src/"
	else

	# INSTALL FOR EVERYTHING ELSE
		trap "trap_No" 1 2 3 6 15
		if [[ -d $DIRECTORY ]]; then
			sudo -u "$USER" mv -f "$DIRECTORY" "$old"
		fi
		if [[ -d $DIRECTORY && $trapSet = true ]]; then
			error_Trap "RESTORING OLD [$NAME_PRETTY]"
			sudo -u "$USER" mv -f "$old/$FOLDER" "$DIRECTORY"
			exit 1
		fi
		sudo -u "$USER" mkdir -p "$DIRECTORY"
		sudo -u "$USER" mv "$tmp/$folderName"/* "$DIRECTORY"

		# KEEP (some) OLD P2POOL FILES
		if [[ $NAME_PRETTY = P2Pool ]]; then
			[[ -f "$old/$FOLDER/p2pool.cache" ]] && mv -f "$old/$FOLDER/p2pool.cache" "$DIRECTORY"
			[[ -f "$old/$FOLDER/p2pool_peers.txt" ]] && mv -f "$old/$FOLDER/p2pool_peers.txt" "$DIRECTORY"
			[[ -f "$old/$FOLDER/p2pool.log" ]] && mv -f "$old/$FOLDER/p2pool.log" "$DIRECTORY"
			[[ -f "$old/$FOLDER/local/stats" ]] && mkdir -p "$DIRECTORY/local" && mv -f "$old/$FOLDER/local/stats" "$DIRECTORY"
		fi
		if [[ -d $DIRECTORY && $trapSet = true ]]; then
			error_Trap "RESTORING OLD [$NAME_PRETTY]"
			sudo -u "$USER" rm -fr "$DIRECTORY"
			sudo -u "$USER" mv -f "$old/$FOLDER" "$DIRECTORY"
			exit 1
		fi
	fi
	# CONFIG
	case $NAME_PRETTY in
		monero-bash)
			[[ -e $config/monero-bash.conf ]] || cp "$installDirectory"/config/monero-bash.conf "$config/"
			parse_Config
			;;
		Monero)
			[[ -e $config/monerod.conf ]] || cp "$installDirectory"/config/monerod.conf "$config/"
			[[ -e $config/monero-wallet-cli.conf ]] || cp "$installDirectory"/config/monero-wallet-cli.conf "$config/"
			;;
		P2Pool)
			[[ -e $config/p2pool.conf ]] || cp "$installDirectory"/config/p2pool.conf "$config/"
			parse_Config
			;;
		XMRig) [[ -e $config/xmrig.json ]] || cp "$installDirectory"/config/xmrig.json "$config/";;
	esac

	if [[ $INSTALL = true ]]; then
		OFF; echo -n "[Install] "
		IGREEN; echo "OK" ;OFF
	else
		OFF; echo -n "[Upgrade] "
		IGREEN; echo "OK" ;OFF
	fi
	upgrade_Post
}

upgrade_Post()
{
	trap "trap_Post" 1 2 3 6 15
	sudo -u "$USER" rm -rf "$old"

	# STATE UPDATE
	print_WhiteHash "Updating local state"
	version_Template
	sudo -u "$USER" sed -i "s@.*"$NAME_CAPS"_VER=.*@"$NAME_CAPS"_VER=\""$NewVer"\"@" "$state"
	sudo -u "$USER" sed -i "s@.*"$NAME_CAPS"_OLD=.*@"$NAME_CAPS"_OLD=\"false\"@" "$state"
	OFF; echo -n "[${NAME_PRETTY}] "
	IGREEN; echo "$NewVer" ;OFF
	[[ $INSTALL = true ]]&& systemd_"$NAME_FUNC"
	PRODUCE_HASH_LIST
	permission_All

	# CLEANUP, FINAL MESSAGE
	tmp_Del
	error_Exit "Could not cleanup tmp folder"
	if [[ $INSTALL = true ]]; then
		print_GreenHash "Installed [$NAME_PRETTY]"
	else
		print_GreenHash "Upgraded [$NAME_PRETTY]"
	fi
	[[ $VERBOSE = true ]]&& verbose_Upgrade
	return 0
}

upgrade_Monero()
{
	local downloadMonero="true"
	define_Monero
	prompt_Sudo;error_Sudo
	upgrade_Pre
	local downloadMonero="false"
}

upgrade_MoneroBash()
{
	define_MoneroBash
	prompt_Sudo;error_Sudo
	upgrade_Pre
}

upgrade_XMRig()
{
	local downloadXMRig="true"
	define_XMRig
	prompt_Sudo;error_Sudo
	upgrade_Pre
	local downloadXMRig="false"
}

upgrade_P2Pool()
{
	local downloadP2Pool="true"
	define_P2Pool
	prompt_Sudo;error_Sudo
	upgrade_Pre
	local downloadP2Pool="false"
}

upgrade_All()
{
	if [[ $MONERO_BASH_VER && $MONERO_BASH_OLD = "true" ]]; then
		upgrade_MoneroBash
	fi
	if [[ $MONERO_VER && $MONERO_OLD = "true" ]]; then
		 upgrade_Monero
	fi
	if [[ $XMRIG_VER && $XMRIG_OLD = "true" ]]; then
		upgrade_XMRig
	fi
	if [[ $P2POOL_VER && $P2POOL_OLD = "true" ]]; then
		upgrade_P2Pool
	fi
	exit 0
}

upgrade_Force()
{
	BWHITE; printf "Packages to upgrade: " ;OFF
	[[ $MONERO_BASH_VER != "" ]]&& printf " [monero-bash] "
	[[ $MONERO_VER != "" ]]&& printf " [Monero] "
	[[ $XMRIG_VER != "" ]]&& printf " [XMRig] "
	[[ $P2POOL_VER != "" ]]&& printf " [P2Pool] "
	echo;echo
	BWHITE; echo -n "Upgrade? (Y/n) " ;OFF
	Yes()
	{
		if [[ $MONERO_BASH_VER ]]; then
			upgrade_MoneroBash
		fi
		if [[ $MONERO_VER ]]; then
			 upgrade_Monero
		fi
		if [[ $XMRIG_VER ]]; then
			upgrade_XMRig
		fi
		if [[ $P2POOL_VER ]]; then
			upgrade_P2Pool
		fi
		exit 0
	}
	No(){ echo "Exiting..." ;exit 1;}
	prompt_YESno
}
