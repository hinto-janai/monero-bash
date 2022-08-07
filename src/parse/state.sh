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

# parse the state file safely
parse::state() {
	log::debug "starting"
	local i IFS=$'\n' STATE_ARRAY STATE_PATH || return 1

	# check relative directory instead of $STATE
	# this is so first time installations can
	# properly find the state file.
	if [[ -e "$RELATIVE/txt/state" ]]; then
		log::debug "state found, using: ${RELATIVE}/txt/state"
		mapfile STATE_ARRAY < "${RELATIVE}/txt/state" || return 2
	else
		print::exit "state file was not found"
	fi

	for i in ${STATE_ARRAY[@]}; do
		[[ $i = FIRST_TIME=true* ]]      && declare -g FIRST_TIME=true
		[[ $i = MONERO_BASH_VER=* ]]     && declare -g MONERO_BASH_VER="${i//*=}"
		[[ $i = MONERO_VER=* ]]          && declare -g MONERO_VER="${i//*=}"
		[[ $i = P2POOL_VER=* ]]          && declare -g P2POOL_VER="${i//*=}"
		[[ $i = XMRIG_VER=* ]]           && declare -g XMRIG_VER="${i//*=}"
		[[ $i = MONERO_BASH_OLD=true* ]] && declare -g MONERO_BASH_OLD=true
		[[ $i = MONERO_OLD=true* ]]      && declare -g MONERO_OLD=true
		[[ $i = P2POOL_OLD=true* ]]      && declare -g P2POOL_OLD=true
		[[ $i = XMRIG_OLD=true* ]]       && declare -g XMRIG_OLD=true
	done

	# FALSE
	[[ $FIRST_TIME != true ]]        && declare -g FIRST_TIME=false
	[[ $MONERO_BASH_OLD != true ]]   && unset -v MONERO_BASH_OLD
	[[ $MONERO_OLD != true ]]        && unset -v MONERO_OLD
	[[ $P2POOL_OLD != true ]]        && unset -v P2POOL_OLD
	[[ $XMRIG_OLD != true ]]         && unset -v XMRIG_OLD

	log::debug "--- state file ---"
	log::debug "FIRST_TIME      | $FIRST_TIME"
	log::debug "MONERO_BASH_VER | $MONERO_BASH_VER"
	log::debug "MONERO_VER      | $MONERO_VER"
	log::debug "P2POOL_VER      | $P2POOL_VER"
	log::debug "XMRIG_VER       | $XMRIG_VER"
	log::debug "MONERO_BASH_OLD | $MONERO_BASH_OLD"
	log::debug "MONERO_OLD      | $MONERO_OLD"
	log::debug "P2POOL_OLD      | $P2POOL_OLD"
	log::debug "XMRIG_OLD       | $XMRIG_OLD"
}