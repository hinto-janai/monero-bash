# This file is part of monero-bash - a wrapper for Monero, written in Bash
#
# Copyright (c) 2022 hinto.janaiyo <https://github.com/hinto-janaiyo>
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

# install for monero-bash
monero_bash::install() {

log::debug "starting monero_bash::install()"

# SAFETY CHECKS
# monero-bash already found
if [[ -d "$HOME"/.monero-bash ]]; then
	print::error "$HOME/.monero-bash already found!"
	print::exit  "Exiting for safety..."
fi
if [[ -e /usr/local/bin/monero-bash ]]; then
	print::error "/usr/local/bin/monero-bash already found!"
	print::exit  "Exiting for safety..."
fi
# path check
local INSTALL_PWD
INSTALL_PWD="$(realpath "$0")"
if [[ $INSTALL_PWD != */monero-bash/monero-bash ]]; then
	print::error "[monero-bash] is not in the monero-bash folder"
	print::exit  "Exiting for safety..."
else
	INSTALL_PWD="$(dirname "$INSTALL_PWD")"
fi

# TITLE
printf "${BRED}%s${OFF}%s\n" \
	"#-----------------------------------------------------------------#" \
	"#                    monero-bash installation                     #" \
	"#-----------------------------------------------------------------#"

# DATA PATH
while :; do
	# check for .bitmonero
	local INSTALL_DATA_PATH
	if [[ -d "$HOME"/.bitmonero ]]; then
		printf "${OFF}%s\n${OFF}%s" \
			"Monero data folder already detected" \
			"Use $HOME/.bitmonero? (Y/n) "
		if ask::yes; then
			INSTALL_DATA_PATH="$HOME/.bitmonero"
		else
			printf "%s\n" "Skipping $HOME/.bitmonero"
		fi
	fi

	# ask for monero data path
	if [[ -z $INSTALL_DATA_PATH ]]; then
		printf "%s" "Monero data path [Enter for default]: "
		read -r INSTALL_DATA_PATH
	fi
	# default path
	if [[ -z $INSTALL_DATA_PATH ]]; then
		INSTALL_DATA_PATH="$HOME/.bitmonero"
	fi

	# confirm monero data path
	printf "${BWHITE}%s${BYELLOW}%s\n${OFF}%s" \
		"DATA PATH: " \
		"$INSTALL_DATA_PATH" \
		"Is this okay? (Y/n) "
	if ask::yes; then
		break
	fi
done

# MB ALIAS
if [[ ! -e /usr/local/bin/mb ]]; then
	printf "${OFF}%s${BRED}%s${OFF}%s${BRED}%s${OFF}\n" \
		"Symlink creation: " \
		"[monero-bash] " \
		"--> " \
		"[mb]"
	printf "${OFF}%s${BRED}%s${OFF}%s${BYELLOW}%s${OFF}\n"
		"This allows you to use " \
		"[monero-bash] " \
		"like so: " \
		"mb update && mb upgrade"
	printf "${OFF}%s" "Create symlink? (Y/n) "
	if ask::yes; then
		local INSTALL_SYMLINK=true
	else
		printf "%s\n" "Skipping symlink..."
	fi
fi

# INSTALLATION INFORMATION
echo
printf "${OFF}%s${BYELLOW}%s\n" \
	"[monero-bash] will install in | " "$HOME/.monero-bash" \
	"The path will be set in       | " "/usr/local/bin/monero-bash" \
	".bitmonero will be set in     | " "$INSTALL_DATA_PATH"
if [[ $INSTALL_SYMLINK = true ]]; then
	printf "${OFF}%s${BYELLOW}%s\n" \
	"A path symlink will be set in | " "/usr/local/bin/mb"
fi
echo
printf "${BWHITE}%s${OFF}\n" \
	"A no-login user called [monero-bash] will be created for process security" \
	"This will be the user Monero and P2Pool runs as"
echo

# INSTALLATION PROMPT
printf "${BWHITE}%s${$BRED}%s${BWHITE}%s${OFF}\n" \
	"Start " \
	"[monero-bash] " \
	"install? (Y/n) "
if ask::yes; then
	printf "${OFF}%s${BRED}%s${OFF}%s\n" \
	"Starting " \
	"[monero-bash] " \
	"install..."
else
	printf "${BWHITE}%s${BRED}%s${BWHITE}%s${OFF}\n" \
		"Canceling " \
		"[monero-bash] " \
		"installation"
	exit 1
fi

# SUDO
if ! ask::sudo; then
	print::exit "sudo is required for installation"
fi

# HASH CHECK
log::prog "verifying monero-bash file hashes"
if sha256sum --quiet --check "src/txt/hashlist"; then
	log::ok "monero-bash file hashes"
else
	log::fail "monero-bash file hashes"
	print::error "Hash verification has failed."
	print::exit "Have the files been moved for modified?"
fi

___BEGIN___ERROR___TRACE___

# USER CREATION
log::prog "creating monero-bash user"
local NOLOGIN_SHELL
NOLOGIN_SHELL="$(which nologin)"
if ! sudo useradd --shell "$NOLOGIN_SHELL" --no-create-home --system; then
	print::error "Could not create monero-bash user"
	print::exit "Exiting for safety..."
fi
log::ok "created monero-bash user"

# FOLDER CREATION
log::prog "creating .monero-bash folders"
mkdir -p packages
mkdir -p packages/monero-bash
mkdir -p wallets
log::ok "created .monero-bash folders"

# COPY MONERO-BASH INTO PACKAGES/
log::prog "copying monero-bash files"
cp -r monero-bash "$PKG_MONERO_BASH"
cp -r src "$PKG_MONERO_BASH"
cp -r gpg "$PKG_MONERO_BASH"
log::prog "copied monero-bash files"

# CLEAN GIT FILES
log::prog "cleaning git files"
[[ -e docs ]]         && rm -rf doc
[[ -e lib ]]          && rm -rf lib
[[ -e tests ]]        && rm -rf tests
[[ -e CHANGELOG.md ]] && rm -rf CHANGELOG.md
[[ -e README.md ]]    && rm -rf README.md
[[ -e LICENSE ]]      && rm -rf LICENSE
[[ -e hbc.add ]]      && rm -f hbc.add
[[ -e hbc.conf ]]     && rm -f hbc.conf
[[ -e main.sh ]]      && rm -f main.sh
log::ok "cleaned git files"

# MOVE TO .monero-bash
log::prog "moving folder to $HOME/.monero-bash"
mkdir "$HOME/.monero-bash"
mv "$INSTALL_PWD" "$HOME/.monero-bash"

# RESET VARIABLES
INSTALL_PWD="$HOME/.monero-bash"
cd "$INSTALL_PWD"
log::prog "moved folder to $HOME/.monero-bash"

# CREATE CONFIG FOLDER
log::prog "creating config folder"
mkdir -p configs
cp "$PKG_MONERO_BASH/configs/monero-bash.conf" "$CONFIG/"
log::ok "created config folder"

# ADD TO PATH
log::prog "adding [monero-bash] to PATH"
sudo ln -s "$INSTALL_PWD/packages/monero-bash/monero-bash" /usr/local/bin/monero-bash
log::ok "added [monero-bash] to PATH"
if [[ $INSTALL_SYMLINK = true ]]; then
	log::prog "creating [mb] PATH symlink"
	sudo ln -s "$INSTALL_PWD/packages/monero-bash/monero-bash" /usr/local/bin/mb
	log::ok "created [mb] PATH symlink"
fi

# SET MONERO DATA PATH
log::prog "setting Monero data path"
sed -i "s/.*data-dir.*/data-dir="$INSTALL_DATA_PATH"/" "$CONFIG_MONEROD"
log::ok "set Monero data path"

# FIRST TIME
sed -i "s/FIRST_TIME=.*/FIRST_TIME=\"false\"/" "$STATE"

# PERMISSIONS
log::prog "setting folder permissions"
sudo chown "$USER:$USER" "$INSTALL_PWD"
sudo chmod -R 755 "$INSTALL_PWD"
log::ok "set folder permissions"

___ENDOF___ERROR___TRACE___

# END
printf "${BGREEN}%s${OFF}%s\n" \
	"#-----------------------------------------------------------------#" \
	"#                monero-bash installation complete                #" \
	"#-----------------------------------------------------------------#"
printf "${BWHITE}%s${BYELLOW}%s\n" \
	"monero-bash path    | " "$HOME/.monero-bash" \
	"Monero data path    | " "$INSTALL_DATA_PATH" \
	"Wallet files        | " "$WALLETS" \
	"Package folders     | " "$PACKAGES" \
	"Configuration files | " "$CONFIG"
echo
printf "${BWHITE}%s${BRED}%s${BWHITE}%s\n" \
	"Type: " \
	"[monero-bash help] " \
	"to get started"
exit 0
}
