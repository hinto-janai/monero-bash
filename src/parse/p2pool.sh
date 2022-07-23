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

# parse [p2pool.conf] safely
parse::p2pool() {
	log::debug "starting ${FUNCNAME}()"
	local i IFS=$'\n' CONFIG_ARRAY || return 1
	mapfile CONFIG_ARRAY < "$CONFIG_P2POOL" || return 2
	for i in "${CONFIG_ARRAY[@]}"; do
		[[ $i =~ ^P2POOL_WALLET=*$ ]]       && declare -g P2POOL_WALLET="${i/*=/}"
		[[ $i =~ ^P2POOL_HOST=*$ ]]         && declare -g P2POOL_HOST="${i/*=/}"
		[[ $i =~ ^P2POOL_RPC_PORT=*$ ]]     && declare -g P2POOL_RPC_PORT="${i/*=/}"
		[[ $i =~ ^P2POOL_ZMQ_PORT=*$ ]]     && declare -g P2POOL_ZMQ_PORT="${i/*=/}"
		[[ $i =~ ^P2POOL_STRATUM=*$ ]]      && declare -g P2POOL_STRATUM="${i/*=/}"
		[[ $i =~ ^P2POOL_P2P=*$ ]]          && declare -g P2POOL_P2P="${i/*=/}"
		[[ $i =~ ^P2POOL_ADD_PEERS=*$ ]]    && declare -g P2POOL_ADD_PEERS="${i/*=/}"
		[[ $i =~ ^P2POOL_LIGHT_MODE=*$ ]]   && declare -g P2POOL_LIGHT_MODE="${i/*=/}"
		[[ $i =~ ^P2POOL_CONFIG=*$ ]]       && declare -g P2POOL_CONFIG="${i/*=/}"
		[[ $i =~ ^P2POOL_LOG_LEVEL=*$ ]]    && declare -g P2POOL_LOG_LEVEL="${i/*=/}"
		[[ $i =~ ^P2POOL_DATA_API=*$ ]]     && declare -g P2POOL_DATA_API="${i/*=/}"
		[[ $i =~ ^P2POOL_LOCAL_API=*$ ]]    && declare -g P2POOL_LOCAL_API="${i/*=/}"
		[[ $i =~ ^P2POOL_NO_CACHE=*$ ]]     && declare -g P2POOL_NO_CACHE="${i/*=/}"
		[[ $i =~ ^P2POOL_NO_COLOR=*$ ]]     && declare -g P2POOL_NO_COLOR="${i/*=/}"
		[[ $i =~ ^P2POOL_NO_RANDOMX=*$ ]]   && declare -g P2POOL_NO_RANDOMX="${i/*=/}"
		[[ $i =~ ^P2POOL_OUT_PEERS=*$ ]]    && declare -g P2POOL_OUT_PEERS="${i/*=/}"
		[[ $i =~ ^P2POOL_IN_PEERS=*$ ]]     && declare -g P2POOL_IN_PEERS="${i/*=/}"
		[[ $i =~ ^P2POOL_START_MINING=*$ ]] && declare -g P2POOL_START_MINING="${i/*=/}"
		[[ $i =~ ^P2POOL_MINI=*$ ]]         && declare -g P2POOL_MINI="${i/*=/}"
		[[ $i =~ ^P2POOL_NO_AUTODIFF=*$ ]]  && declare -g P2POOL_NO_AUTODIFF="${i/*=/}"
		[[ $i =~ ^P2POOL_RPC_LOGIN=*$ ]]    && declare -g P2POOL_RPC_LOGIN="${i/*=/}"
	done

	# DEFAULTS
	[[ -z $P2POOL_HOST ]]             && declare -g P2POOL_HOST=127.0.0.1
	[[ -z $P2POOL_RPC_PORT ]]         && declare -g P2POOL_RPC_PORT=18081
	[[ -z $P2POOL_ZMQ_PORT ]]         && declare -g P2POOL_ZMQ_PORT=18083
	[[ $P2POOL_LIGHT_MODE != true ]]  && declare -g P2POOL_LIGHT_MODE=false
	[[ -z $P2POOL_LOG_LEVEL ]]        && declare -g P2POOL_LOG_LEVEL=2
	[[ $P2POOL_NO_CACHE != true ]]    && declare -g P2POOL_NO_CACHE=false
	[[ $P2POOL_NO_COLOR != true ]]    && declare -g P2POOL_NO_COLOR=false
	[[ $P2POOL_NO_RANDOMX != true ]]  && declare -g P2POOL_NO_RANDOMX=false
	[[ $P2POOL_MINI != true ]]        && declare -g P2POOL_MINI=false
	[[ $P2POOL_NO_AUTODIFF != true ]] && declare -g P2POOL_NO_AUTODIFF=false

	# PARSING OPTIONS INTO A SINGLE COMMAND
	declare -g P2POOL_COMMAND || return 3
	P2POOL_COMMAND="--wallet $P2POOL_WALLET"
	P2POOL_COMMAND="$P2POOL_COMMAND --host $P2POOL_HOST"
	P2POOL_COMMAND="$P2POOL_COMMAND --rpc-port $P2POOL_RPC_PORT"
	P2POOL_COMMAND="$P2POOL_COMMAND --zmq-port $P2POOL_ZMQ_PORT"
	[[ $P2POOL_STRATUM ]]            && P2POOL_COMMAND="$P2POOL_COMMAND --stratum $P2POOL_STRATUM"
	[[ $P2POOL_P2P ]]                && P2POOL_COMMAND="$P2POOL_COMMAND --p2p $P2POOL_P2P"
	[[ $P2POOL_ADD_PEERS ]]          && P2POOL_COMMAND="$P2POOL_COMMAND --addpeers $P2POOL_ADD_PEERS"
	[[ $P2POOL_LIGHT_MODE = true ]]  && P2POOL_COMMAND="$P2POOL_COMMAND --light-mode"
	P2POOL_COMMAND="$P2POOL_COMMAND --loglevel $P2POOL_LOG_LEVEL"
	[[ $P2POOL_CONFIG ]]             && P2POOL_COMMAND="$P2POOL_COMMAND --config $P2POOL_CONFIG"
	[[ $P2POOL_DATA_API ]]           && P2POOL_COMMAND="$P2POOL_COMMAND --data-api $P2POOL_DATA_API"
	[[ $P2POOL_LOCAL_API ]]          && P2POOL_COMMAND="$P2POOL_COMMAND --local-api $P2POOL_LOCAL_API"
	[[ $P2POOL_NO_CACHE = true ]]    && P2POOL_COMMAND="$P2POOL_COMMAND --no-cache"
	[[ $P2POOL_NO_COLOR = true ]]    && P2POOL_COMMAND="$P2POOL_COMMAND --no-color"
	[[ $P2POOL_NO_RANDOMX = true ]]  && P2POOL_COMMAND="$P2POOL_COMMAND --no-randomx"
	[[ $P2POOL_OUT_PEERS ]]          && P2POOL_COMMAND="$P2POOL_COMMAND --out-peers $P2POOL_OUT_PEERS"
	[[ $P2POOL_IN_PEERS ]]           && P2POOL_COMMAND="$P2POOL_COMMAND --in-peers $P2POOL_IN_PEERS"
	[[ $P2POOL_START_MINING ]]       && P2POOL_COMMAND="$P2POOL_COMMAND --start-mining $P2POOL_START_MINING"
	[[ $P2POOL_MINI = true ]]        && P2POOL_COMMAND="$P2POOL_COMMAND --mini"
	[[ $P2POOL_NO_AUTODIFF = true ]] && P2POOL_COMMAND="$P2POOL_COMMAND --no-autodiff"
	[[ $P2POOL_RPC_LOGIN ]]          && P2POOL_COMMAND="$P2POOL_COMMAND --rpc-login $P2POOL_RPC_LOGIN"

	# log::debug
	log::debug "--- p2pool.conf settings ---"
	log::debug "P2POOL_WALLET       | $P2POOL_WALLET"
	log::debug "P2POOL_HOST         | $P2POOL_HOST"
	log::debug "P2POOL_RPC_PORT     | $P2POOL_RPC_PORT"
	log::debug "P2POOL_ZMQ_PORT     | $P2POOL_ZMQ_PORT"
	log::debug "P2POOL_STRATUM      | $P2POOL_STRATUM"
	log::debug "P2POOL_P2P          | $P2POOL_P2P"
	log::debug "P2POOL_ADD_PEERS    | $P2POOL_ADD_PEERS"
	log::debug "P2POOL_LIGHT_MODE   | $P2POOL_LIGHT_MODE"
	log::debug "P2POOL_CONFIG       | $P2POOL_CONFIG"
	log::debug "P2POOL_LOG_LEVEL    | $P2POOL_LOG_LEVEL"
	log::debug "P2POOL_DATA_API     | $P2POOL_DATA_API"
	log::debug "P2POOL_LOCAL_API    | $P2POOL_LOCAL_API"
	log::debug "P2POOL_NO_CACHE     | $P2POOL_NO_CACHE"
	log::debug "P2POOL_NO_COLOR     | $P2POOL_NO_COLOR"
	log::debug "P2POOL_NO_RANDOMX   | $P2POOL_NO_RANDOMX"
	log::debug "P2POOL_OUT_PEERS    | $P2POOL_OUT_PEERS"
	log::debug "P2POOL_IN_PEERS     | $P2POOL_IN_PEERS"
	log::debug "P2POOL_START_MINING | $P2POOL_START_MINING"
	log::debug "P2POOL_MINI         | $P2POOL_MINI"
	log::debug "P2POOL_NO_AUTODIFF  | $P2POOL_NO_AUTODIFF"
	log::debug "P2POOL_RPC_LOGIN    | $P2POOL_RPC_LOGIN"
	log::debug "final p2pool command: $P2POOL_COMMAND"
	return 0
}
