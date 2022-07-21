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

# prompt for removing packages
# uses variables from parse/options.sh
# continues to remove()
remove::prompt() {
	log::debug "starting removal prompt"

	# CREATE REMOVAL LIST
	local REMOVAL_LIST || return 1
	if [[ $OPTION_REMOVE_BASH = true ]]; then
		printf "${OFF}%s\n%s${BYELLOW}%s${OFF}%s\n" \
			"[monero-bash] ($MONERO_BASH_VER) cannot be removed normally"
			"type: " \
			"[monero-bash uninstall]" \
			"to cleanly uninstall monero-bash from your system"
		exit 1
	fi
	[[ $OPTION_REMOVE_MONERO = true ]] && REMOVE_LIST="$REMOVE_LIST [monero]"
	[[ $OPTION_REMOVE_P2POOL = true ]] && REMOVE_LIST="$REMOVE_LIST [p2pool]"
	[[ $OPTION_REMOVE_XMRIG = true ]]  && REMOVE_LIST="$REMOVE_LIST [xmrig]"

	# CHECK IF PACKAGE IS INSTALLED
	if [[ $OPTION_REMOVE_MONERO = true && -z $MONERO_VER ]]; then
		printf "${OFF}%s\n" "[monero] is not installed"
		REMOVE_LIST="${REMOVE_LIST/\[monero\]}"
	fi
	if [[ $OPTION_REMOVE_P2POOL = true && -z $P2POOL_VER ]]; then
		printf "${OFF}%s\n" "[p2pool] is not installed"
		REMOVE_LIST="${REMOVE_LIST/\[p2pool\]}"
	fi
	if [[ $OPTION_REMOVE_XMRIG = true && -z $XMRIG_VER ]]; then
		printf "${OFF}%s\n" "[xmrig] is not installed"
		REMOVE_LIST="${REMOVE_LIST/\[xmrig\]}"
	fi
	[[ $REMOVE_LIST = " " ]] && exit 1

	# PROMPT
	printf "${BWHITE}%s${OFF}%s\n\n${BWHITE}%s" \
		"Packages to remove: " \
		"$REMOVE_LIST" \
		"Continue with removal? (y/N) "
	if ask::no; then
		print::exit "Canceling installation"
	fi

	# SUDO
	if ! ask::sudo; then
		print::exit "sudo is required"
	fi

	# START REMOVAL
	[[ $OPTION_REMOVE_MONERO = true ]] && struct::pkg monero && remove
	[[ $OPTION_REMOVE_P2POOL = true ]] && struct::pkg p2pool && remove
	[[ $OPTION_REMOVE_XMRIG = true ]]  && struct::pkg xmrig  && remove
}
