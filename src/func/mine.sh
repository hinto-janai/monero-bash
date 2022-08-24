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

# all-in-one mining functions
# invoked by "monero-bash <cmd> all"

mine_Start()
{
	prompt_Sudo;error_Sudo
	[[ $AUTO_HUGEPAGES = true ]] && mine_Hugepages
	[[ $MONERO_VER ]] && missing_Monero && define_Monero && process_Start
	[[ $P2POOL_VER ]] && missing_P2Pool && define_P2Pool && process_Start
	[[ $XMRIG_VER ]]  && missing_XMRig && define_XMRig && process_Start
	printf "Watch with: "
	BWHITE; echo "[monero-bash watch <monero/p2pool/xmrig>]" ;OFF
	return 0
}

mine_Stop()
{
	prompt_Sudo;error_Sudo
	[[ $MONERO_VER ]] && define_Monero && process_Stop
	[[ $P2POOL_VER ]] && define_P2Pool && process_Stop
	[[ $XMRIG_VER ]]  && define_XMRig && process_Stop
	return 0
}

mine_Restart()
{
	prompt_Sudo;error_Sudo
	[[ $MONERO_VER ]] && define_Monero && process_Restart
	[[ $P2POOL_VER ]] && define_P2Pool && process_Restart
	[[ $XMRIG_VER ]]  && define_XMRig && process_Restart
	return 0
}

mine_Hugepages()
{
    # set default if not specified in monero-bash.conf
    [[ -z $HUGEPAGES ]] && HUGEPAGES="3072"
    BWHITE; echo "Setting hugepage: $HUGEPAGES" ;OFF
    sudo sysctl vm.nr_hugepages="$HUGEPAGES" > /dev/null
    error_Continue "Could not set hugepages..."
}

mine_Config()
{
	while :; do
    BRED; echo "#-----------------------------------------#"
    BRED; echo "#   P2Pool & XMRig mining configuration   #"
    BRED; echo "#-----------------------------------------#"

	# wallet + daemon ip + pool ip + mini config
	unset -v WALLET IP RPC ZMQ POOL MINI LOG OUT_PEERS IN_PEERS
	while :; do
		BWHITE; printf "WALLET ADDRESS: " ;OFF
		read -r WALLET
		if [[ $WALLET ]]; then
			break
		else
			print_Error "Empty input!"
		fi
	done
	echo

	UYELLOW; BYELLOW; printf "%s\n" "Hit [enter] to select the [default] if you don't know what to input."
	IWHITE; printf "Pool IP [default: 127.0.0.1:3333]        | " ;OFF
	read -r POOL
	IWHITE; printf "Monero Node IP [default: 127.0.0.1]      | " ;OFF
	read -r DAEMON_IP
	IWHITE; printf "Monero RPC port [default: 18081]         | " ;OFF
	read -r DAEMON_RPC
	IWHITE; printf "Monero ZMQ port [default: 18083]         | " ;OFF
	read -r DAEMON_ZMQ
	IWHITE; printf "P2Pool OUT peers (10-1000) [default: 10] | " ;OFF
	read -r OUT_PEERS
	IWHITE; printf "P2Pool IN peers (10-1000) [default: 10]  | " ;OFF
	read -r IN_PEERS
	IWHITE; printf "P2Pool Log Level (0-6) [default: 3]      | " ;OFF
	read -r LOG_LEVEL
	IWHITE; printf "Use P2Pool Mini-Pool? (Y/n)              | " ;OFF
	Yes(){ MINI="true" ;}
	No(){ MINI="false" ;}
	prompt_YESno
	echo

	# repeat & confirm user input
	BBLUE; printf "WALLET ADDRESS   | " ;OFF; echo "$WALLET"

	BBLUE; printf "POOL IP          | " ;OFF
	[[ $POOL ]] || POOL="127.0.0.1:3333"
	echo "$POOL"

	BBLUE; printf "MONERO NODE IP   | " ;OFF
	[[ $DAEMON_IP ]] || DAEMON_IP="127.0.0.1"
	echo "$DAEMON_IP"

	BBLUE; printf "MONERO RPC PORT  | " ;OFF
	[[ $DAEMON_RPC ]] || DAEMON_RPC="18081"
	echo "$DAEMON_RPC"

	BBLUE; printf "MONERO ZMQ PORT  | " ;OFF
	[[ $DAEMON_ZMQ ]] || DAEMON_ZMQ="18083"
	echo "$DAEMON_ZMQ"

	BBLUE; printf "P2POOL OUT PEERS | " ;OFF
	[[ $IN_PEERS ]] || IN_PEERS="10"
	echo "$IN_PEERS"

	BBLUE; printf "P2POOL IN PEERS  | " ;OFF
	[[ $OUT_PEERS ]] || OUT_PEERS="10"
	echo "$OUT_PEERS"

	BBLUE; printf "P2POOL LOG LEVEL | " ;OFF
	[[ $LOG_LEVEL ]] || LOG_LEVEL="3"
	echo "$LOG_LEVEL"

	BBLUE; printf "P2POOL MINI      | " ;OFF; echo "$MINI"

	BWHITE; printf "Use these settings? (Y/n) "

	# set user input if yes, repeat if no
	Yes()
	{
		prompt_Sudo ; error_Sudo
		safety_HashList
		trap "" 1 2 3 6 15

		# p2pool.conf
		echo "Editing [p2pool.conf]..."
		sudo -u "$USER" sed \
				-i -e "s/^DAEMON_IP=.*$/DAEMON_IP=${DAEMON_IP}/" "$config/p2pool.conf" \
				-i -e "s/^DAEMON_RPC=.*$/DAEMON_RPC=${DAEMON_RPC}/" "$config/p2pool.conf" \
				-i -e "s/^DAEMON_ZMQ=.*$/DAEMON_ZMQ=${DAEMON_ZMQ}/" "$config/p2pool.conf" \
				-i -e "s/^OUT_PEERS=.*$/OUT_PEERS=${OUT_PEERS}/" "$config/p2pool.conf" \
				-i -e "s/^IN_PEERS=.*$/IN_PEERS=${IN_PEERS}/" "$config/p2pool.conf" \
				-i -e "s/^WALLET=.*$/WALLET=${WALLET}/" "$config/p2pool.conf" \
				-i -e "s/^MINI=.*$/MINI=${MINI}/" "$config/p2pool.conf" \
				-i -e "s/^LOG_LEVEL=.*$/LOG_LEVEL=${LOG_LEVEL}/" "$config/p2pool.conf"

		# re-source
		source "$config/monero-bash.conf" &>/dev/null
		source "$config/p2pool.conf" &>/dev/null

		# re-create systemd file
		systemd_P2Pool

		# xmrig.json
		echo "Editing [xmrig.json]..."
		sudo -u "$USER" sed \
			-i -e "s@\"user\":.*@\"user\": \"${WALLET}\",@" "$xmrigConf" \
			-i -e "s@\"url\":.*@\"url\": \"${POOL}\",@" "$xmrigConf"

		# state file
		sudo -u "$USER" sed -i "s@.*MINE_UNCONFIGURED.*@MINE_UNCONFIGURED=false@" "$state"
		# p2pool mini state
		if [[ $MINI = true ]]; then
			sudo -u "$USER" echo "MINI_FLAG='--mini'" > "$MB_API/mini"
		else
			sudo -u "$USER" echo "MINI_FLAG=" > "$MB_API/mini"
		fi
		PRODUCE_HASH_LIST
		echo
		BGREEN; echo "Mining configuration complete!"
		OFF; echo -n "To get started: "
		BWHITE; echo "[monero-bash start all]"
	}
	No(){ :; }
	local yn
    read yn
    if [[ $yn = "" || $yn = "y" || $yn = "Y" ||$yn = "yes" || $yn = "Yes" ]]; then
        Yes
        break
    else
        No
    fi
	done
}
