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

# monero-bash install/uninstall functions

###################################################   START OF INSTALL FUNCTION   ###################################################
monerobash_Install()
{
	# x86_64 check
	safety::x86_64

	BRED; echo "#-----------------------------------------------------------------#"
	BRED; echo -n "#                 "
	BRED; echo -n "monero-bash $MONERO_BASH_VER installation"
	BRED; echo "                 #"
	BRED; echo "#-----------------------------------------------------------------#"

while true ;do
	# $HOME/.bitmonero check
	if [[ -d "$HOME/.bitmonero" ]]; then
		BWHITE; echo "Monero data folder detected!"
		OFF; echo -n "Use "
		BYELLOW; echo -n "[${HOME}/.bitmonero]"
		OFF; echo -n "? (Y/n): "
		Yes(){ alreadyFoundDataPath="true" ;}
		No(){ :;}
		prompt_YESno
	fi
	if [[ $alreadyFoundDataPath != "true" ]]; then
		BWHITE; echo -n "Monero data path [Enter for default]: " ;IWHITE
		read inputData
	fi

	# Data Path Confirmation
	if [[ $alreadyFoundDataPath = "true" ]]; then
		BWHITE; echo -n "Data path: "
		BYELLOW; echo "[${HOME}/.bitmonero]"
		OFF; echo -n "Is this okay? (Y/n) "
		Yes(){ echo "Data path set!" ;yes="true";}
		No(){ :;}
		prompt_YESno
	else
		BWHITE; echo -n "Data path: "
		if [[ $inputData ]]; then
			BYELLOW; echo "$inputData"
		else
			BYELLOW; echo "$HOME/.bitmonero"
		fi
		OFF; echo -n "Is this okay? (Y/n) "
		Yes(){ echo "Data path set!" ;yes="true";}
		No(){ :;}
		prompt_YESno
	fi
	[[ "$yes" = "true" ]] && echo && break
done

# MB ALIAS
if [[ ! -e /usr/local/bin/mb && ! -h /usr/local/bin/mb ]]; then
	BYELLOW; printf "%s\n" "Symlink creation: [monero-bash] -> [mb]"
	BWHITE; printf "%s" "This allows you use monero-bash like so: "
	BCYAN; printf "%s\n" "[mb update && mb upgrade]"; OFF
	printf "%s" "Create symlink? (Y/n) "
	read -r YES_NO
	case $YES_NO in
		y|Y|yes|Yes|YES|"")
			local INSTALL_SYMLINK=true
			printf "%s\n" "Will create [mb] symlink!"
			;;
		*)
			printf "%s\n" "Skipping [mb] symlink..."
			;;
	esac
	echo
fi

# INSTALLATION INFORMATION
local i
BRED; printf "%s" "#"
for ((i=0; i < 65; i++)); do
	read -r -t 0.01 || true
	printf "%s" "-"
done
printf "%s\n\n" "#"; OFF
printf "\e[0m%s\e[1;93m%s\n" \
	"Install     | " "/usr/local/share/monero-bash" \
	"PATH        | " "/usr/local/bin/monero-bash"
if [[ $INSTALL_SYMLINK = true ]]; then
	printf "\e[0m%s\e[1;93m%s\n" "Symlink     | " "/usr/local/bin/mb"
fi
printf "\e[0m%s\e[1;93m%s\n" "User folder | " "${HOME}/.monero-bash"
if [[ $inputData ]]; then
	printf "\e[0m%s\e[1;93m%s\n" "Monero data | " "$inputData"
else
	printf "\e[0m%s\e[1;93m%s\n" "Monero data | " "${HOME}/.bitmonero"
fi
echo

# Installation Prompt
	BWHITE; echo -n "Start "
	BRED; echo -n "[monero-bash] "
	BWHITE; echo -n "install? (Y/n) "
	Yes(){ OFF; echo "Starting..." ;}
	No(){ OFF; echo "Exiting..." ;exit;}
	prompt_YESno
	prompt_Sudo
	error_Exit "Sudo is required to install monero-bash"

# Check if already installed
if [[ -e /usr/local/share/monero-bash ]]; then
	BRED; printf "ERROR: "
	BWHITE; echo "/usr/local/share/monero-bash already detected!"
	exit
fi

# Hash Integrity Check
	print_GreenHash "Checking monero-bash hash integrity"
	QUIET_HASH_LIST
	alreadyCheckedHashList="true"

# TRAP
trap "" 1 2 3 6 15

# Deleting Git Files
	print_GreenHash "Cleaning up git files"
	[[ -d "$installDirectory/.git" ]]&& sudo rm -r "$installDirectory/.git"
	[[ -f "$installDirectory/.gitignore" ]]&& sudo rm -r "$installDirectory/.gitignore"
	[[ -f "$installDirectory/LICENSE" ]]&& sudo rm "$installDirectory/LICENSE"
	[[ -f "$installDirectory/README.md" ]]&& sudo rm "$installDirectory/README.md"
	[[ -f "$installDirectory/CHANGELOG.md" ]]&& sudo rm "$installDirectory/CHANGELOG.md"
	[[ -d "$installDirectory/docs" ]]&& sudo rm -r "$installDirectory/docs"
	[[ -d "$installDirectory/.old" ]]&& sudo rm -r "$installDirectory/.old"
	[[ -d "$installDirectory/tests" ]]&& sudo rm -r "$installDirectory/tests"
	[[ -d "$installDirectory/utils" ]]&& sudo rm -r "$installDirectory/utils"
	[[ -d "$installDirectory/external" ]]&& sudo rm -r "$installDirectory/external"

# Moving to /usr/local/
	print_GreenHash "Installing monero-bash in /usr/local/share/monero-bash/"
	sudo mv "$installDirectory" "/usr/local/share/"

# Resetting variables
	installDirectory="/usr/local/share/monero-bash"
	source "/usr/local/share/monero-bash/src/source.sh"
	permission_InstallDirectory
	cd "/usr/local/share/monero-bash"

# Adding to PATH + symlink
	print_GreenHash "Adding monero-bash to PATH"
	path_Add
	if [[ $INSTALL_SYMLINK = true ]]; then
		print_GreenHash "Creating [mb] symlink"
		sudo ln -s /usr/local/share/monero-bash/monero-bash /usr/local/bin/mb
	fi

# Building $HOME/.monero-bash
	print_GreenHash "Building /.monero-bash/ folders"
	if [[ $alreadyFoundDataPath = "true" ]]; then
		build_Template
	else
		build_DotMoneroBash
	fi

# Setting Data Path
	print_GreenHash "Setting data path"
	if [[ $inputData ]]; then
		sed -i "s|^data-dir.*|data-dir=${inputData}|" "$config/monerod.conf"
	else
		sed -i "s|^data-dir.*|data-dir=${HOME}/.bitmonero|" "$config/monerod.conf"
	fi

# First Time = false , Set Installed User , chown
sudo sed \
	-i -e "s|.*FIRST_TIME.*|FIRST_TIME=false|g" "$state" \
	-i -e "s|.*INSTALLED_USER.*|INSTALLED_USER=\"${USER}\"|g" "$state"
sudo chown -R "$USER:$USER" "$installDirectory"
permission_All
PRODUCE_HASH_LIST

#
#                       End
#
echo
BRED; echo "#-----------------------------------------------------------------#"
BRED; echo "#                monero-bash installation complete                #"
BRED; echo "#-----------------------------------------------------------------#"
OFF; echo -n "Install     | "; BYELLOW; echo "/usr/local/share/monero-bash"
OFF; echo -n "Packages    | "; BYELLOW; echo "/usr/local/share/monero-bash/bin"
OFF; echo -n "PATH        | "; BYELLOW; echo "/usr/local/bin/monero-bash"
if [[ $INSTALL_SYMLINK = true ]]; then
	OFF; echo -n "Symlink     | "; BYELLOW; echo "/usr/local/bin/mb"
fi
OFF; echo -n "User folder | "; BYELLOW; echo "$dotMoneroBash"
OFF; echo -n "Monero data | "; BYELLOW
if [[ $inputData ]]; then
	echo "$inputData"
else
	echo "$HOME/.bitmonero"
fi
echo

if [[ $INSTALL_SYMLINK = true ]]; then
	OFF; echo -n "Type: "
	BCYAN; echo -n "[monero-bash help] "
	OFF; echo -n "OR "
	BCYAN; echo -n "[mb help] "
	OFF; echo "to get started"
else
	OFF; echo -n "Type: "
	BCYAN; echo -n "[monero-bash help] "
	OFF; echo "to get started"
fi
exit 0
}
###################################################   END OF INSTALL FUNCTION   ###################################################

monerobash_Uninstall()
{
	BWHITE; echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
	BWHITE; echo -n "@   "
	BRED; echo -n "THIS WILL UNINSTALL monero-bash, DELETE /.monero-bash/ AND EVERYTHING INSIDE IT"
	BWHITE; echo "   @"
	BWHITE; echo -n "@                         "
	BRED; echo -n "It will NOT delete \$HOME/.bitmonero"
	BWHITE; echo "                         @"
	BWHITE; echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
	print_Size
	BWHITE; echo -n "Uninstall "
	IRED; echo -n "monero-bash? "
	BWHITE; echo -n "(y/N) "
	Yes()
	{
		# if wallets are found, warn user
		walletCount="$(ls "$wallets" | wc -l)"
		if [[ "$walletCount" -gt 0 ]]; then
			echo
			BWHITE; echo -n "@@@@@@@@@@@@"
			BRED; echo -n "      WALLETS FOUND      "
			BWHITE; echo "@@@@@@@@@@@@"
			BWHITE; ls "$wallets"
			BRED; echo -n "ARE YOU SURE YOU WANT TO UNINSTALL? (y/N) " ;BWHITE
			Yes(){ : ;}
			No(){ OFF; echo "Exiting..." ;exit;}
			prompt_NOyes
		fi
		prompt_Sudo
		error_Exit "Sudo is needed to uninstall"

		# 5 second countdown
		for i in {5..0} ;do
			tput sc
			if [[ "$i" = "0" ]]; then
				BRED; echo -n "Uninstalling..."
			else
				BRED; echo -n "Uninstalling in $i..."
			fi
			sleep 1
			if [[ $i != "0" ]]; then
				tput rc;tput el
			else
				echo;echo
			fi
		done

		# Hash Integrity Check
		print_GreenHash "Checking monero-bash hash integrity"
		QUIET_HASH_LIST

		# stop all running processes
		mine_Stop

		# removal
		trap "" 1 2 3 6 15
		print_WhiteHash "Removing $dotMoneroBash"
			sudo rm -rf "$dotMoneroBash"
			error_Exit "$dotMoneroBash not removed"
		print_WhiteHash "Removing from PATH"
			path_Remove
			error_Exit "PATH not removed"
		if [[ -h /usr/local/bin/mb ]]; then
			print_WhiteHash "Removing [mb] symlink"
			sudo rm /usr/local/bin/mb
		fi
		print_WhiteHash "Removing /usr/local/share/monero-bash/"
			sudo rm -rf "/usr/local/share/monero-bash"
			error_Exit "monero-bash not removed"
		print_WhiteHash "Removing systemd services"
			define_Monero
				if [[ -e "$sysd/$SERVICE" ]]; then
					sudo rm "$sysd/$SERVICE"
					error_Continue "$SERVICE not removed"
					[[ -e "/etc/systemd/system/multi-user.target.wants/$SERVICE" ]] && sudo rm "/etc/systemd/system/multi-user.target.wants/$SERVICE"
				fi
			define_XMRig
				if [[ -e "$sysd/$SERVICE" ]]; then
					sudo rm "$sysd/$SERVICE"
					error_Continue "$SERVICE not removed"
					[[ -e "/etc/systemd/system/multi-user.target.wants/$SERVICE" ]] && sudo rm "/etc/systemd/system/multi-user.target.wants/$SERVICE"
					fi
			define_P2Pool
				if [[ -e "$sysd/$SERVICE" ]]; then
					sudo rm "$sysd/$SERVICE"
					error_Continue "$SERVICE not removed"
					[[ -e "/etc/systemd/system/multi-user.target.wants/$SERVICE" ]] && sudo rm "/etc/systemd/system/multi-user.target.wants/$SERVICE"
				fi
		print_GreenHash "monero-bash has been uninstalled"
	}
	No(){ OFF; echo "Exiting..." ;exit;}
	prompt_NOyes
}
