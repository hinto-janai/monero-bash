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

# Upgrade prompt. Creates the UPGRADE_LIST array.
# Called by: upgrade()
#            install()

upgrade::prompt() {
	log::debug "starting ${FUNCNAME}()"

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
	[[ $OPTION_VERBOSE = true ]] && printf "${BBLUE}%s${OFF}\n" "$PROMPT_VERB verbosely...!"
	[[ $OPTION_FORCE = true ]]   && printf "${BBLUE}%s${OFF}\n" "$PROMPT_VERB forcefully...!"

	# CREATE UPGRADE LIST
	local UPGRADE_LIST
	[[ $OPTION_BASH = true ]]   && UPGRADE_LIST="[monero-bash]"
	[[ $OPTION_MONERO = true ]] && UPGRADE_LIST="$UPGRADE_LIST [monero]"
	[[ $OPTION_P2POOL = true ]] && UPGRADE_LIST="$UPGRADE_LIST [p2pool]"
	[[ $OPTION_XMRIG = true ]]  && UPGRADE_LIST="$UPGRADE_LIST [xmrig]"

	# CHECK IF PACKAGE IS ALREADY UPGRADED
	if [[ $OPTION_FORCE != true ]]; then
		if [[ $OPTION_BASH = true && $MONERO_BASH_OLD != true ]]; then
			printf "${OFF}%s\n" "[monero-bash] ($MONERO_BASH_VER) is up to date"
			UPGRADE_LIST="${UPGRADE_LIST/\[monero-bash\]}"
		fi
		if [[ $OPTION_MONERO = true && $MONERO_OLD != true ]]; then
			printf "${OFF}%s\n" "[monero] ($MONERO_VER) is up to date"
			UPGRADE_LIST="${UPGRADE_LIST/\[monero\]}"
		fi
		if [[ $OPTION_P2POOL = true && $P2POOL_OLD != true ]]; then
			printf "${OFF}%s\n" "[p2pool] ($P2POOL_VER) is up to date"
			UPGRADE_LIST="${UPGRADE_LIST/\[p2pool\]}"
		fi
		if [[ $OPTION_XMRIG = true && $XMRIG_OLD != true ]]; then
			printf "${OFF}%s\n" "[xmrig] ($XMRIG_VER) is up to date"
			UPGRADE_LIST="${UPGRADE_LIST/\[xmrig\]}"
		fi
		if [[ $UPGRADE_LIST = " " || -z $UPGRADE_LIST ]]; then
			log::debug "UPGRADE_LIST is empty, exiting"
			exit 1
		fi
	fi

	# PROMPT
	printf "${BWHITE}%s${OFF}%s\n\n${BWHITE}%s" \
		"Packages to $PROMPT_NOUN: " \
		"$UPGRADE_LIST" \
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
	upgrade
}
