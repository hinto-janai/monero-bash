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
	declare -g CONFIG_GREP=$(config::grep "$config/monero-bash.conf" \
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
		bool   TOR_BROWSER_MIMIC    \
		bool   ONLY_USER_AGENT      \
		bool   ONLY_WGET_CURL       \
		bool   HTTP_HEADERS_VERBOSE \
		port   DAEMON_RPC_IP        \
		bool   DAEMON_RPC_VERBOSE   \
		bool   AUTO_HUGEPAGES       \
		int    HUGEPAGES
	) || { printf "\e[1;31m%s\n" "[MONERO BASH FATAL ERROR] monero-bash.conf source failure" || panic; }

	# default for empty values
	[[ $AUTO_START_DAEMON ]]    || { declare -g AUTO_START_DAEMON=false || panic; }
	[[ $AUTO_STOP_DAEMON ]]     || { declare -g AUTO_STOP_DAEMON=false || panic; }
	[[ $AUTO_UPDATE ]]          || { declare -g AUTO_UPDATE=false || panic; }
	[[ $PRICE_API_IP_WARNING ]] || { declare -g PRICE_API_IP_WARNING=false || panic; }
	[[ $USE_TOR ]]              || { declare -g USE_TOR=false || panic; }
	[[ $TOR_PROXY ]]            || { declare -g TOR_PROXY=127.0.0.1:9050 || panic; }
	[[ $TEST_TOR ]]             || { declare -g TEST_TOR=false || panic; }
	[[ $TOR_QUIET ]]            || { declare -g TOR_QUIET=false || panic; }
	[[ $FAKE_HTTP_HEADERS ]]    || { declare -g FAKE_HTTP_HEADERS=false || panic; }
	[[ $TOR_BROWSER_MIMIC ]]    || { declare -g TOR_BROWSER_MIMIC=false || panic; }
	[[ $ONLY_USER_AGENT ]]      || { declare -g ONLY_USER_AGENT=false || panic; }
	[[ $ONLY_WGET_CURL ]]       || { declare -g ONLY_WGET_CURL=false || panic; }
	[[ $HTTP_HEADERS_VERBOSE ]] || { declare -g HTTP_HEADERS_VERBOSE=false || panic; }
	[[ $DAEMON_RPC_IP ]]        || { declare -g DAEMON_RPC_IP=127.0.0.1:18081 || panic; }
	[[ $DAEMON_RPC_VERBOSE ]]   || { declare -g DAEMON_RPC_VERBOSE=false || panic; }
	[[ $AUTO_HUGEPAGES ]]       || { declare -g AUTO_HUGEPAGES=false || panic; }
	[[ $HUGEPAGES ]]            || { declare -g HUGEPAGES=3072 || panic; }
	# range [1-60]
	[[ $WATCH_REFRESH_RATE -ge 1 && $WATCH_REFRESH_RATE -le 60 ]] || { declare -g WATCH_REFRESH_RATE=5 || panic; }
	# split tor ip/port
	[[ $TOR_PROXY ]] && { declare -g TOR_IP=${TOR_PROXY/:*} TOR_PORT=${TOR_PROXY/*:} || panic; }

	# [p2pool.conf]
	[[ $P2POOL_VER ]] || return 0
	declare -g CONFIG_GREP=$(config::grep "$p2poolConf" \
		char  WALLET     \
		bool  MINI       \
		ip    DAEMON_IP  \
		int   DAEMON_RPC \
		int   DAEMON_ZMQ \
		pos   OUT_PEERS  \
		pos   IN_PEERS   \
		[0-6] LOG_LEVEL
	) || { printf "\e[1;31m%s\n" "[MONERO BASH FATAL ERROR] p2pool.conf source failure" || panic; }
	# range [10-1000]
	if [[ $OUT_PEERS ]]; then
		[[ $OUT_PEERS -ge 10 && $OUT_PEERS -le 1000 ]] || { declare -g OUT_PEERS=10 || panic; }
	fi
	if [[ $IN_PEERS ]]; then
		[[ $IN_PEERS -ge 10 && $IN_PEERS -le 1000 ]] || { declare -g IN_PEERS=10 || panic; }
	fi
	# default for empty values
	# covered by [process.sh] & [systemd.sh]
	# (in a really messy way)
}
