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

# Package install/upgrade prompt. Creates the UPGRADE_LIST array.
pkg::prompt() {
	log::debug "starting"

	# CHANGE BEHAVIOR ON INSTALL
	local PROMPT_VERB PROMPT_NOUN
	if [[ $1 = install ]]; then
		PROMPT_VERB="Installing"
		PROMPT_NOUN="install"
	else
		PROMPT_VERB="Upgrading"
		PROMPT_NOUN="upgrade"
	fi

	# CHECK FOR VERBOSE/FORCE
	if [[ $OPTION_VERBOSE = true ]]; then
		STD_LOG_DEBUG=true
		printf "${BBLUE}%s${OFF}\n" "$PROMPT_VERB verbosely...!"
	fi
	[[ $OPTION_FORCE = true ]]   && printf "${BBLUE}%s${OFF}\n" "$PROMPT_VERB forcefully...!"

	# CREATE UPGRADE LIST (install)
	char UPGRADE_LIST
	if [[ $1 = install ]]; then
		[[ $OPTION_BASH = true ]]   && UPGRADE_LIST="bash"
		[[ $OPTION_MONERO = true ]] && UPGRADE_LIST="$UPGRADE_LIST monero"
		[[ $OPTION_P2POOL = true ]] && UPGRADE_LIST="$UPGRADE_LIST p2pool"
		[[ $OPTION_XMRIG = true ]]  && UPGRADE_LIST="$UPGRADE_LIST xmrig"
		# check if already installed (if --force is not given)
		if [[ $OPTION_FORCE != true ]]; then
			for i in $UPGRADE_LIST; do
				struct::pkg $i
				pkg::prompt::check::install
			done
		fi
	# CREATE UPGRADE LIST (upgrade)
	elif [[ $1 = upgrade ]]; then
		[[ $MONERO_BASH_VER ]] && UPGRADE_LIST="bash"
		[[ $MONERO_VER ]]      && UPGRADE_LIST="$UPGRADE_LIST monero"
		[[ $P2POOL_VER ]]      && UPGRADE_LIST="$UPGRADE_LIST p2pool"
		[[ $XMRIG_VER ]]       && UPGRADE_LIST="$UPGRADE_LIST xmrig"
		# check if pkg is old (if --force is not given)
		if [[ $OPTION_FORCE != true ]]; then
			for i in $UPGRADE_LIST; do
				struct::pkg $i
				pkg::prompt::check::old
			done
		fi
	fi

	# EXIT ON EMPTY LIST
	if [[ $UPGRADE_LIST =~ ^[[:space:]]+$ || -z $UPGRADE_LIST ]]; then
		log::debug "UPGRADE_LIST is empty, exiting"
		exit 1
	fi

	# CREATE UI LIST
	local PROMPT_UPGRADE_LIST i
	for i in $UPGRADE_LIST; do
		case "$i" in
			bash)   PROMPT_UPGRADE_LIST="$PROMPT_UPGRADE_LIST  [monero-bash]";;
			monero) PROMPT_UPGRADE_LIST="$PROMPT_UPGRADE_LIST  [Monero]";;
			p2pool) PROMPT_UPGRADE_LIST="$PROMPT_UPGRADE_LIST  [P2Pool]";;
			xmrig) PROMPT_UPGRADE_LIST="$PROMPT_UPGRADE_LIST  [XMRig]";;
		esac
	done

	# PROMPT
	printf "${BWHITE}%s${OFF}%s\n\n${BWHITE}%s${OFF}" \
		"Packages to $PROMPT_NOUN: " \
		"$PROMPT_UPGRADE_LIST" \
		"Continue with ${PROMPT_NOUN}? (Y/n) "
	if ! ask::yes; then
		print::exit "Canceling $PROMPT_NOUN"
	fi

	# SUDO
	if ! ask::sudo; then
		print::exit "sudo is required"
	fi

	# START UPGRADE
	log::debug "starting $PROMPT_NOUN of packages: $UPGRADE_LIST"
	pkg::upgrade $1
}

# check if pkg is installed
pkg::prompt::check::install() {
	log::debug "starting | ${PKG[pretty]}"

	# if pkg is installed
	if [[ ${PKG[current_version]} ]]; then
		printf "${OFF}%s\n" "[${PKG[pretty]}] (${PKG[current_version]}) is already installed | skipping"
		UPGRADE_LIST="${UPGRADE_LIST//${PKG[short]}}"
	fi
}

pkg::prompt::check::old() {
	log::debug "starting | ${PKG[pretty]}"

	# if pkg is old
	if [[ ${PKG[old]} != true ]]; then
		printf "${OFF}%s\n" "[${PKG[pretty]}] (${PKG[current_version]}) is up to date | skipping"
		UPGRADE_LIST="${UPGRADE_LIST//${PKG[short]}}"
	fi
}
