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

	# CREATE UPGRADE LIST
	local UPGRADE_LIST
	[[ $OPTION_BASH = true ]]   && UPGRADE_LIST="bash"
	[[ $OPTION_MONERO = true ]] && UPGRADE_LIST="$UPGRADE_LIST monero"
	[[ $OPTION_P2POOL = true ]] && UPGRADE_LIST="$UPGRADE_LIST p2pool"
	[[ $OPTION_XMRIG = true ]]  && UPGRADE_LIST="$UPGRADE_LIST xmrig"

	# CHECK IF PACKAGE IS ALREADY UP TO DATE
	if [[ $OPTION_FORCE != true ]]; then
		if [[ $OPTION_BASH = true && $MONERO_BASH_OLD != true ]]; then
			printf "${OFF}%s\n" "[monero-bash] ($MONERO_BASH_VER) is up to date"
			UPGRADE_LIST="${UPGRADE_LIST//bash}"
		fi
		if [[ $OPTION_MONERO = true && $MONERO_OLD != true ]]; then
			printf "${OFF}%s\n" "[Monero] ($MONERO_VER) is up to date"
			UPGRADE_LIST="${UPGRADE_LIST//monero}"
		fi
		if [[ $OPTION_P2POOL = true && $P2POOL_OLD != true ]]; then
			printf "${OFF}%s\n" "[P2Pool] ($P2POOL_VER) is up to date"
			UPGRADE_LIST="${UPGRADE_LIST//p2pool}"
		fi
		if [[ $OPTION_XMRIG = true && $XMRIG_OLD != true ]]; then
			printf "${OFF}%s\n" "[XMRig] ($XMRIG_VER) is up to date"
			UPGRADE_LIST="${UPGRADE_LIST//xmrig}"
		fi
		if [[ $UPGRADE_LIST =~ ^[[:space:]]+$ || -z $UPGRADE_LIST ]]; then
			log::debug "UPGRADE_LIST is empty, exiting"
			exit 1
		fi
	fi

	# CHECK IF INSTALLED OR NOT (for upgrade)
	if [[ $1 = upgrade ]]; then
		if [[ $OPTION_BASH = true && -z $MONERO_BASH_VER ]]; then
			printf "${OFF}%s\n" "[monero-bash] is not installed | skipping"
			UPGRADE_LIST="${UPGRADE_LIST//bash}"
		fi
		if [[ $OPTION_MONERO = true && -z $MONERO_VER ]]; then
			printf "${OFF}%s\n" "[Monero] is not installed | skipping"
			UPGRADE_LIST="${UPGRADE_LIST//monero}"
		fi
		if [[ $OPTION_P2POOL = true && -z $P2POOL_VER ]]; then
			printf "${OFF}%s\n" "[P2Pool] is not installed | skipping"
			UPGRADE_LIST="${UPGRADE_LIST//p2pool}"
		fi
		if [[ $OPTION_XMRIG = true && -z $XMRIG_VER ]]; then
			printf "${OFF}%s\n" "[XMRig] is not installed | skipping"
			UPGRADE_LIST="${UPGRADE_LIST//xmrig}"
		fi
		if [[ $UPGRADE_LIST =~ [[:space:]] || -z $UPGRADE_LIST ]]; then
			log::debug "UPGRADE_LIST is empty, exiting"
			exit 1
		fi
	fi

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
	UPGRADE_LIST=("$UPGRADE_LIST")
	UPGRADE_LIST=("${UPGRADE_LIST[@]//[}")
	UPGRADE_LIST=("${UPGRADE_LIST[@]//]}")
	pkg::upgrade install
}
