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

# delete the [monero-bash] user
monero_bash::install:trap::user() {
	trap "" INT
	log::prog "Deleting user [monero-bash]"
	if sudo userdel monero-bash; then
		log::ok "Deleted user [monero-bash]"
	else
		log::fail "Could not delete user [monero-bash]"
	fi
}

# clean $DOT, $BINARY, $SYMLINK
monero_bash::install::trap::clean() {
	print::error "Install failed, starting cleanup"
	trap "" INT

	# DELETE DOT
	if [[ -d "$DOT" ]]; then
		log::debug "DOT found: $DOT"
		log::prog "Deleting: $DOT"
		if rm -rf "$DOT" &>/dev/null; then
			log::ok "Deleted: $DOT"
		else
			log::fail "Could not delete: $DOT"
		fi
	else
		log::debug "no DOT found at: $DOT"
	fi

	# DELETE PATH
	if [[ -e "$BINARY" || -h "$BINARY" ]]; then
		log::debug "BINARY found: $BINARY"
		log::prog "Deleting: $BINARY"
		if sudo rm -rf "$BINARY" &>/dev/null; then
			log::ok "Deleted: $BINARY"
		else
			log::fail "Could not delete: $BINARY"
		fi
	else
		log::debug "no BINARY found at: $BINARY"
	fi

	# DELETE SYMLINK IF WE CREATED IT
	if [[ -e "$SYMLINK" || -h "$SYMLINK" ]]; then
		local SYMLINK_OUTPUT="$(ls "$SYMLINK")"
		if [[ $SYMLINK_OUTPUT = *${BINARY}* ]]; then
			log::prog "SYMLINK found: $SYMLINK"
			log::prog "Deleting: $SYMLINK"
			if sudo rm -rf "$SYMLINK" &>/dev/null; then
				log::ok "Deleted: $SYMLINK"
			else
				log::fail "Could not delete: $SYMLINK"
			fi
		else
			log::debug "no SYMLINK found at: $SYMLINK"
		fi
	fi
	exit 0
}

# install for monero-bash
monero_bash::install() {

log::debug "starting ${FUNCNAME}()"

# SAFETY CHECKS
# monero-bash already found
if [[ -d "$HOME"/.monero-bash ]]; then
	print::error "[monero-bash] install folder already found: $HOME/.monero-bash"
	print::exit  "Exiting for safety..."
fi
if [[ -e "$BINARY" || -h "$BINARY" ]]; then
	print::error "/usr/local/bin/monero-bash already found!"
	print::exit  "Exiting for safety..."
fi

# TITLE
printf "${BRED}%s${OFF}\n" \
	"#-----------------------------------------------------------------#" \
	"#                    monero-bash installation                     #" \
	"#-----------------------------------------------------------------#"

# DATA PATH
# check for .bitmonero
local INSTALL_DATA_PATH
if [[ -d "$HOME"/.bitmonero ]]; then
	printf "${OFF}%s\n%s${BYELLOW}%s${OFF}%s" \
		"Monero data folder already detected" \
		"Use " \
		"$HOME/.bitmonero? " \
		"(Y/n) "
	if ask::yes; then
		INSTALL_DATA_PATH="$HOME/.bitmonero"
	else
		printf "%s\n\n" "Skipping: $HOME/.bitmonero"
	fi
fi

while :; do
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
	printf "\n${BWHITE}%s${BYELLOW}%s\n${OFF}%s" \
		"DATA PATH: " \
		"$INSTALL_DATA_PATH" \
		"Is this okay? (Y/n) "
	if ask::yes; then
		echo
		break
	else
		unset -v INSTALL_DATA_PATH
	fi
	echo
done

# MB ALIAS
if [[ ! -e $SYMLINK && ! -h $SYMLINK ]]; then
	printf "${OFF}%s${BRED}%s${OFF}%s${BRED}%s${OFF}\n" \
		"Symlink creation: " \
		"[monero-bash] " \
		"-> " \
		"[mb]"
	printf "${OFF}%s${BRED}%s${OFF}%s${BCYAN}%s${OFF}\n" \
		"This allows you to use " \
		"[monero-bash] " \
		"like so: " \
		"mb update && mb upgrade"
	printf "${OFF}%s" "Create symlink? (Y/n) "
	if ask::yes; then
		local INSTALL_SYMLINK=true
		printf "%s\n" "Will create [mb] symlink"
	else
		printf "%s\n" "Skipping [mb] symlink..."
	fi
fi

# INSTALLATION INFORMATION
local i
# CONFIRM
printf "\n${BRED}%s" "#"
for ((i=0; i < 65; i++)); do
	read -r -t 0.01 || true
	printf "%s" "-"
done
printf "${BRED}%s${OFF}\n\n" "#"

printf "${OFF}%s${BYELLOW}%s\n" \
	"[monero-bash] will install in | " "$HOME/.monero-bash" \
	"The PATH will be set in       | " "/usr/local/bin/monero-bash" \
	"[.bitmonero] will be set in   | " "$INSTALL_DATA_PATH"
if [[ $INSTALL_SYMLINK = true ]]; then
	printf "${OFF}%s${BYELLOW}%s\n" \
	"A PATH symlink will be set in | " "/usr/local/bin/mb"
fi
echo
printf "${BWHITE}%s${OFF}\n" \
	"A no-login user called [monero-bash] will be created for process security" \
	"[Monero] and [P2Pool] will run as this user. [XMRig] by default, runs as ROOT." \
	"This can be changed in [monero-bash.conf]: XMRIG_ROOT=false"
echo

# INSTALLATION PROMPT
printf "${BWHITE}%s${BRED}%s${BWHITE}%s${OFF}" \
	"Start " \
	"[monero-bash] " \
	"install? (Y/n) "
if ! ask::yes; then
	printf "$${OFF}%s\n" "Canceling [monero-bash] installation..."
	exit 1
fi

# SUDO
if ! ask::sudo; then
	print::exit "sudo is required for installation"
fi

# HASH CHECK
log::prog "verifying [monero-bash] file hashes"
if sha256sum --check "txt/hashlist" &>/dev/null; then
	log::ok "[monero-bash] file hashes"
else
	log::fail "[monero-bash] file hashes"
	print::error "Hash verification has failed."
	print::exit "Have the files been moved for modified?"
fi

# USER CREATION
log::prog "creating [monero-bash] user"
local NOLOGIN_SHELL
NOLOGIN_SHELL="$(which nologin)"
log::debug "[nologin] shell found: $NOLOGIN_SHELL"

trap 'monero_bash::install::trap::clean' EXIT

if ! sudo useradd --no-create-home --system --shell "$NOLOGIN_SHELL" monero-bash; then
	print::error "Could not create [monero-bash] user"
	print::exit "Exiting for safety..."
else
	trap 'monero::install::trap::user; monero_bash::install::trap::clean' EXIT
	log::ok "created [monero-bash] user"
fi

# FOLDER CREATION
log::prog "creating [.monero-bash] folders"
mkdir "$DOT"
mkdir "$PACKAGES"
mkdir "$PKG_MONERO_BASH"
mkdir "$WALLETS"
log::ok "created [.monero-bash] folders"

# CLEAN GIT FILES
log::prog "cleaning git files"
[[ -e docs ]]         && rm -rf doc
[[ -e lib ]]          && rm -rf lib
[[ -e tests ]]        && rm -rf tests
[[ -e utils ]]        && rm -rf utils
[[ -e src ]]          && rm -rf src
[[ -e pgp ]]          && rm -rf pgp
[[ -e CHANGELOG.md ]] && rm -f CHANGELOG.md
[[ -e README.md ]]    && rm -f README.md
[[ -e LICENSE ]]      && rm -f LICENSE
[[ -e hbc.add ]]      && rm -f hbc.add
[[ -e hbc.conf ]]     && rm -f hbc.conf
[[ -e main.sh ]]      && rm -f main.sh
[[ -e .git ]]         && rm -rf .git
[[ -e .gitignore ]]   && rm -f .gitignore
[[ -e .gitmodules ]]  && rm -f .gitmodules
log::ok "cleaned git files"

# MOVE TO .monero-bash
log::prog "moving folder to: [$HOME/.monero-bash]"
mv -f "$RELATIVE" "$PACKAGES"
log::ok "moved folder to: [$HOME/.monero-bash]"

# CREATE CONFIG FOLDER
log::prog "creating config folder"
mkdir -p "$CONFIG"
cp "$SRC_CONFIG/monero-bash.conf" "$CONFIG/"
cp "$SRC_CONFIG/monerod.conf" "$CONFIG/"
cp "$SRC_CONFIG/monero-wallet-cli.conf" "$CONFIG/"
log::ok "created config folder"

# ADD TO PATH
log::prog "adding [monero-bash] to PATH"
sudo ln -s "$MAIN" /usr/local/bin/monero-bash
log::ok "added [monero-bash] to PATH"
if [[ $INSTALL_SYMLINK = true ]]; then
	log::prog "creating [mb] PATH symlink"
	sudo ln -s "$MAIN" /usr/local/bin/mb
	log::ok "created [mb] PATH symlink"
fi

# SET MONERO DATA PATH
log::prog "setting Monero data path"
sed -i "s@data-dir.*@data-dir=$INSTALL_DATA_PATH@g" "$CONFIG_MONEROD"
log::ok "set Monero data path"

# FIRST TIME
log::debug "setting FIRST_TIME = false"
sed -i "s/FIRST_TIME=.*/FIRST_TIME=\"false\"/g" "$STATE"
log::debug "set FIRST_TIME = false"

# PERMISSIONS
log::prog "setting folder permissions"
sudo chown "$USER:$USER" "$DOT"
sudo chmod -R 770 "$DOT"
log::ok "set folder permissions"

# DISARM TRAP
trap - EXIT

# END
printf "${BGREEN}%s${OFF}\n" \
	"" \
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
