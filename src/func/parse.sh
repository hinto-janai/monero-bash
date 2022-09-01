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

# Parsing config files safely.
parse_Config() {
	# [monero-bash.conf]
	declare -g $(config::grep "$config/monero-bash.conf" \
		bool   AUTO_START_DAEMON    \
		bool   AUTO_STOP_DAEMON     \
		bool   AUTO_UPDATE          \
		bool   PRICE_API_IP_WARNING \
		pos    WATCH_REFRESH_RATE   \
		port   DAEMON_RPC_IP        \
		bool   DAEMON_RPC_VERBOSE   \
		bool   AUTO_HUGEPAGES       \
		int    HUGEPAGES
	)
	# default for empty values
	[[ $AUTO_START_DAEMON ]]    || declare -g AUTO_START_DAEMON=false
	[[ $AUTO_STOP_DAEMON ]]     || declare -g AUTO_STOP_DAEMON=false
	[[ $AUTO_UPDATE ]]          || declare -g AUTO_UPDATE=false
	[[ $PRICE_API_IP_WARNING ]] || declare -g PRICE_API_IP_WARNING=false
	[[ $DAEMON_RPC_IP ]]        || declare -g DAEMON_RPC_IP=127.0.0.1:18081
	[[ $DAEMON_RPC_VERBOSE ]]   || declare -g DAEMON_RPC_VERBOSE=false
	[[ $AUTO_HUGEPAGES ]]       || declare -g AUTO_HUGEPAGES=false
	[[ $HUGEPAGES ]]            || declare -g HUGEPAGES=3072
	# range [1-60]
	[[ $WATCH_REFRESH_RATE -ge 1 && $WATCH_REFRESH_RATE -le 60 ]] || declare -g WATCH_REFRESH_RATE=1

	# [p2pool.conf]
	[[ $P2POOL_VER ]] || return 0
	declare -g $(config::grep "$p2poolConf" \
		char  WALLET     \
		bool  MINI       \
		ip    DAEMON_IP  \
		int   DAEMON_RPC \
		int   DAEMON_ZMQ \
		pos   OUT_PEERS  \
		pos   IN_PEERS   \
		[0-6] LOG_LEVEL
	)
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