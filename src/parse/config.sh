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

# parse [monero-bash.conf] safely
parse::config() {
	log::debug "starting ${FUNCNAME}()"
	local i IFS=$'\n' CONFIG_ARRAY CONFIG_PATH || return 1

	# check relative directory instead of $CONFIG
	# this is so first time installations can
	# properly find the config file.
	if [[ -e "${RELATIVE}/config/monero-bash.conf" ]]; then
		log::debug "config found, using: ${RELATIVE}/config/monero-bash.conf"
		mapfile CONFIG_ARRAY < "${RELATIVE}/config/monero-bash.conf" || return 2
	else
		print::exit "[monero-bash.conf] not found"
	fi

	for i in ${CONFIG_ARRAY[@]}; do
		[[ $i =~ ^AUTO_START_MONEROD=true*$ ]]        && declare -g AUTO_START_MONEROD=true
		[[ $i =~ ^AUTO_STOP_MONEROD=true*$ ]]         && declare -g AUTO_STOP_MONEROD=true
		[[ $i =~ ^XMRIG_ROOT=true*$ ]]                && declare -g XMRIG_ROOT=true
		[[ $i =~ ^AUTO_UPDATE=true*$ ]]               && declare -g AUTO_UPDATE=true
		[[ $i =~ ^RPC_IP=* ]]                         && declare -g RPC_IP="${i/*=/}"
		[[ $i =~ ^MONERO_BASH_DEBUG=true*$ ]]         && declare -g STD_LOG_DEBUG=true
		[[ $i =~ ^MONERO_BASH_DEBUG_VERBOSE=true*$ ]] && declare -g STD_LOG_DEBUG_VERBOSE=true
	done

	# DEFAULTS
	[[ $AUTO_START_MONEROD != true ]]        && declare -g AUTO_START_MONEROD=false
	[[ $AUTO_STOP_MONEROD != true ]]         && declare -g AUTO_STOP_MONEROD=false
	[[ $XMRIG_ROOT != true ]]                && declare -g XMRIG_ROOT=false
	[[ $AUTO_UPDATE != true ]]               && declare -g AUTO_UPDATE=false
	[[ -z $RPC_IP ]]                         && declare -g RPC_IP="localhost:18081"
	[[ $MONERO_BASH_DEBUG != true ]]         && declare -g MONERO_BASH_DEBUG=false
	[[ $MONERO_BASH_DEBUG_VERBOSE != true ]] && declare -g MONERO_BASH_DEBUG_VERBOSE=false

	log::debug "--- monero-bash.conf settings ---"
	log::debug "AUTO_START_MONEROD        | $AUTO_START_MONEROD"
	log::debug "AUTO_STOP_MONEROD         | $AUTO_STOP_MONEROD"
	log::debug "XMRIG_ROOT                | $XMRIG_ROOT"
	log::debug "AUTO_UPDATE               | $AUTO_UPDATE"
	log::debug "RPC_IP                    | $RPC_IP"
	log::debug "RPC_VERBOSE               | $RPC_VERBOSE"
	log::debug "MONERO_BASH_DEBUG         | $STD_LOG_DEBUG"
	log::debug "MONERO_BASH_DEBUG_VERBOSE | $STD_LOG_DEBUG_VERBOSE"
}
