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

# prompt for installing packages
# uses variables from parse/options.sh
install() {
	log::debug "starting installation prompt"

	# CHECK FOR VERBOSE/FORCE
	[[ $OPTION_VERBOSE = true ]] && printf "${BBLUE}%s${OFF}\n" "Installing verbosely...!"
	[[ $OPTION_FORCE = true ]]   && printf "${BBLUE}%s${OFF}\n" "Installing forcefully...!"

	# CREATE INSTALL LIST
	local INSTALL_LIST || return 1
	[[ $OPTION_INSTALL_BASH = true ]]   && INSTALL_LIST="[monero-bash]"
	[[ $OPTION_INSTALL_MONERO = true ]] && INSTALL_LIST="$INSTALL_LIST [monero]"
	[[ $OPTION_INSTALL_P2POOL = true ]] && INSTALL_LIST="$INSTALL_LIST [p2pool]"
	[[ $OPTION_INSTALL_XMRIG = true ]]  && INSTALL_LIST="$INSTALL_LIST [xmrig]"

	# CHECK IF PACKAGE IS ALREADY INSTALLED
	if [[ $OPTION_INSTALL_BASH = true && $MONERO_BASH_VER ]]; then
		printf "${OFF}%s\n" "[monero-bash] ($MONERO_BASH_VER) is already installed"
		INSTALL_LIST="${INSTALL_LIST/\[monero-bash\]}"
	fi
	if [[ $OPTION_INSTALL_MONERO = true && $MONERO_VER ]]; then
		printf "${OFF}%s\n" "[monero] ($MONERO_VER) is already installed"
		INSTALL_LIST="${INSTALL_LIST/\[monero\]}"
	fi
	if [[ $OPTION_INSTALL_P2POOL = true && $P2POOL_VER ]]; then
		printf "${OFF}%s\n" "[p2pool] ($P2POOL_VER) is already installed"
		INSTALL_LIST="${INSTALL_LIST/\[p2pool\]}"
	fi
	if [[ $OPTION_INSTALL_XMRIG = true && $XMRIG_VER ]]; then
		printf "${OFF}%s\n" "[xmrig] ($XMRIG_VER) is already installed"
		INSTALL_LIST="${INSTALL_LIST/\[xmrig\]}"
	fi
	[[ $INSTALL_LIST = " " ]] && exit 1

	# PROMPT
	printf "${BWHITE}%s${OFF}%s\n\n${BWHITE}%s" \
		"Packages to install: " \
		"$INSTALL_LIST" \
		"Continue with installation? (Y/n) "
	if ! ask::yes; then
		print::exit "Canceling installation"
	fi

	# START UPGRADE
	[[ $OPTION_INSTALL_MONERO = true ]] && struct::pkg monero && upgrade
	[[ $OPTION_INSTALL_P2POOL = true ]] && struct::pkg p2pool && upgrade
	[[ $OPTION_INSTALL_XMRIG = true ]]  && struct::pkg xmrig  && upgrade
}
