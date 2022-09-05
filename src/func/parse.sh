# This file is part of [monero-bash]
#
# Copyright (c) 2022 hinto.janaiyo
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
#
# Parts of this project are originally:
# Copyright (c) 2019-2022, jtgrassie
# Copyright (c) 2014-2022, The Monero Project
# Copyright (c) 2011-2022, Dominic Tarr
#
# Parts of this project are licensed under GPLv2:
# Copyright (c) ????-2022, Tamas Szerb <toma@rulez.org>
# Copyright (c) 2008-2022, Robert Hogan <robert@roberthogan.net>
# Copyright (c) 2008-2022, David Goulet <dgoulet@ev0ke.net>
# Copyright (c) 2008-2022, Alex Xu (Hello71) <alex_y_xu@yahoo.ca>

# Parse config files safely.
parse_Config() {
	# [monero-bash.conf]
	local CONFIG_GREP=$(config::grep "$config/monero-bash.conf" \
		bool   AUTO_START_DAEMON    \
		bool   AUTO_STOP_DAEMON     \
		bool   AUTO_UPDATE          \
		bool   PRICE_API_IP_WARNING \
		pos    WATCH_REFRESH_RATE   \
		bool   USE_TOR              \
		bool   TOR_QUIET            \
		port   TOR_PROXY            \
		bool   TEST_TOR             \
		bool   FAKE_HTTP_HEADERS    \
		bool   ONLY_USER_AGENT      \
		bool   HTTP_HEADERS_VERBOSE \
		port   DAEMON_RPC_IP        \
		bool   DAEMON_RPC_VERBOSE   \
		bool   AUTO_HUGEPAGES       \
		int    HUGEPAGES
	)
	[[ $CONFIG_GREP ]] || printf "\e[1;31m%s\n" "[MONERO BASH FATAL ERROR] monero-bash.conf source failure"
	declare -g $CONFIG_GREP
	# default for empty values
	[[ $AUTO_START_DAEMON ]]    || declare -g AUTO_START_DAEMON=false
	[[ $AUTO_STOP_DAEMON ]]     || declare -g AUTO_STOP_DAEMON=false
	[[ $AUTO_UPDATE ]]          || declare -g AUTO_UPDATE=false
	[[ $PRICE_API_IP_WARNING ]] || declare -g PRICE_API_IP_WARNING=false
	[[ $USE_TOR ]]              || declare -g USE_TOR=false
	[[ $TOR_PROXY ]]            || declare -g TOR_PROXY=127.0.0.1:9050
	[[ $TEST_TOR ]]             || declare -g TEST_TOR=false
	[[ $TOR_QUIET ]]            || declare -g TOR_QUIET=false
	[[ $FAKE_HTTP_HEADERS ]]    || declare -g FAKE_HTTP_HEADERS=false
	[[ $HTTP_HEADERS_VERBOSE ]] || declare -g HTTP_HEADERS_VERBOSE=false
	[[ $DAEMON_RPC_IP ]]        || declare -g DAEMON_RPC_IP=127.0.0.1:18081
	[[ $DAEMON_RPC_VERBOSE ]]   || declare -g DAEMON_RPC_VERBOSE=false
	[[ $AUTO_HUGEPAGES ]]       || declare -g AUTO_HUGEPAGES=false
	[[ $HUGEPAGES ]]            || declare -g HUGEPAGES=3072
	# range [1-60]
	[[ $WATCH_REFRESH_RATE -ge 1 && $WATCH_REFRESH_RATE -le 60 ]] || declare -g WATCH_REFRESH_RATE=1
	# split tor ip/port
	[[ $TOR_PROXY ]] && declare -g TOR_IP=${TOR_PROXY/:*} TOR_PORT=${TOR_PROXY/*:}

	# [p2pool.conf]
	[[ $P2POOL_VER ]] || return 0
	CONFIG_GREP=$(config::grep "$p2poolConf" \
		char  WALLET     \
		bool  MINI       \
		ip    DAEMON_IP  \
		int   DAEMON_RPC \
		int   DAEMON_ZMQ \
		pos   OUT_PEERS  \
		pos   IN_PEERS   \
		[0-6] LOG_LEVEL
	)
	[[ $CONFIG_GREP ]] || printf "\e[1;31m%s\n" "[MONERO BASH FATAL ERROR] p2pool.conf source failure"
	declare -g $CONFIG_GREP
	# range [10-1000]
	if [[ $OUT_PEERS ]]; then
		[[ $OUT_PEERS -ge 10 && $OUT_PEERS -le 1000 ]] || declare -g OUT_PEERS=10
	fi
	if [[ $IN_PEERS ]]; then
		[[ $IN_PEERS -ge 10 && $IN_PEERS -le 1000 ]] || declare -g IN_PEERS=10
	fi
	# default for empty values
	# covered by [process.sh] & [systemd.sh]
	# (in a really messy way)
}
