# Original code taken from: https://github.com/jtgrassie/xmrpc
# Modified slightly to work within monero-bash as a function.
#
# Copyright (c) 2014-2022, The Monero Project
#
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
# list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its contributors
# may be used to endorse or promote products derived from this software without
# specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

rpc_Daemon()
{
quote() {
    [[ "$1" =~ ^[0-9]+$ ]] && echo -n "$1" && return
    [[ "$1" =~ ^true|false$ ]] && echo -n "$1" && return
    [[ "${1::1}" == "[" ]] && echo -n "$(parse_arr $1)" && return
    echo -n "\"$1\""
}

parse_arr() {
    let e=${#1}-2
    sz=${1:1:$e}
    a=(${sz//,/ })
    for i in "${!a[@]}"; do
        a[$i]=$(quote ${a[i]})
    done
    aj=$(printf ",%s" "${a[@]}")
    aj=${aj:1}
    echo -n "[${aj}]"
}

parse_nv() {
    nv=(${1//:/ })
    c=${#nv[@]}
    [[ $c == 2 ]] && echo -n "$(quote ${nv[0]}):$(quote ${nv[1]})"
}

if [[ "$1" == *:* ]]; then
    DAEMON_RPC_IP="$1/json_rpc"
	shift
elif [[ "$1" != *:* && -z "$DAEMON_RPC_IP" ]]; then
    DAEMON_RPC_IP="http://localhost:18081/json_rpc"
elif [[ "$1" != *:* && ! -z "$DAEMON_RPC_IP" ]]; then
	DAEMON_RPC_IP="${DAEMON_RPC_IP}/json_rpc"
fi

method="$1" ; shift
payload="{\"jsonrpc\":\"2.0\",\"id\":\"0\",\"method\":\"$method\""
if [ -n "$1" ]; then
    if [[ "${1::1}" == "[" ]]; then
        payload="$payload,\"params\":$(parse_arr $1)"
    else
        payload="$payload,\"params\":{"
        while [ -n "$1" ]; do
            payload="${payload}$(parse_nv $1)"
            [ -n "$2" ] && payload="$payload,"
            shift
        done
        payload="$payload}"
    fi
fi
payload="$payload}"

# Set [Wget/Curl] HTTP header for RPC calls
if [[ $FAKE_HTTP_HEADERS = true && $DAEMON_RPC_IP != localhost* && $DAEMON_RPC_IP != 127.0.0.1* && $DAEMON_RPC_IP != 192.168.* ]]; then
	declare -g RPC_CALL=true ONLY_USER_AGENT=true ONLY_WGET_CURL=true
	header_Random
fi

if [[ $USE_TOR = true && $DAEMON_RPC_IP != localhost* && $DAEMON_RPC_IP != 127.0.0.1* && $DAEMON_RPC_IP != 192.168.* ]]; then
	torsocks_init
	[[ $TOR_QUIET = true ]] || echo
	torsocks_func wget \
		-qO- \
		"$DAEMON_RPC_IP" \
		"${WGET_HTTP_HEADERS[@]}" --post-data=$payload
else
	wget \
		-qO- \
		"$DAEMON_RPC_IP" \
		"${WGET_HTTP_HEADERS[@]}" --post-data=$payload
fi
if [[ $? != 0 ]]; then
	print_Error "Monero RPC connection failed"
	exit 1
else
	echo
fi

if [[ $DAEMON_RPC_VERBOSE = true ]]; then
	echo
	BWHITE; printf "DAEMON_RPC_IP: " ;OFF; echo "$DAEMON_RPC_IP"
	BWHITE; printf "PAYLOAD: " ;OFF; echo "$payload"
fi
}
