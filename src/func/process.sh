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

# for interacting with monerod/p2pool/xmrig

process_Start_Template()
{
	# SUDO NOT NEEDED FOR MONEROD
	if [[ $NAME_PRETTY != "Monero" ]]; then
		prompt_Sudo;error_Sudo
	fi

	# CHECK IF MISSING BINARY
	missing_"$NAME_FUNC"

	# CONFIGURE P2POOL (only once)
	if [[ $MINE_UNCONFIGURED = "true" && $PROCESS = "p2pool" ]]; then
		printf "%s\n%s" \
			"First time [P2Pool] detected!" \
			"Would you like to enter configure mode? (Y/n) "
		local YES_NO
		read YES_NO
		case $YES_NO in
			y|Y|yes|Yes|YES|"") mine_Config; exit;;
			*) echo "Skipping...";;
		esac
	fi

	# START PROCESS IF NOT ALREADY ALIVE
	if pgrep $PROCESS &>/dev/null ; then
        $bred; echo "[${PROCESS}] already detected!" ;$off
		return 1
    else
		missing_config_"$NAME_FUNC"

		# REFRESH LOGS
		if [[ $NAME_PRETTY = "P2Pool" && -e "$binP2Pool/p2pool.log" ]]; then
			sudo rm "$binP2Pool/p2pool.log"
		elif [[ $NAME_PRETTY = "XMRig" && -e "$binXMRig/xmrig-log" ]]; then
			sudo rm "$binXMRig/xmrig-log"
			sudo touch "$binXMRig/xmrig-log"
			sudo chown "$USER:$USER" "$binXMRig/xmrig-log"
		fi

		# START PROCESS
		$bblue; echo "Starting [${PROCESS}]..." ;$off
		COMMANDS
		error_Exit "Could not start [${PROCESS}]"
	fi
}

process_Stop_Template()
{
	prompt_Sudo;error_Sudo
	if pgrep $PROCESS &>/dev/null ; then
		COMMANDS
	else
		$off; echo -n "[${PROCESS}] "
		$bred; echo "not online" ;$off
	fi
}

process_Restart()
{
	prompt_Sudo;error_Sudo
	missing_config_"$NAME_FUNC"

	# REFRESH LOGS
	if [[ $NAME_PRETTY = "P2Pool" && -e "$binP2Pool/p2pool.log" ]]; then
		sudo rm "$binP2Pool/p2pool.log"
	elif [[ $NAME_PRETTY = "XMRig" && -e "$binXMRig/xmrig-log" ]]; then
		sudo rm "$binXMRig/xmrig-log"
		sudo touch "$binXMRig/xmrig-log"
		sudo chown "$USER:$USER" "$binXMRig/xmrig-log"
	fi

	# RESTART
	if pgrep $PROCESS &>/dev/null ; then
		$byellow; echo "Restarting [${PROCESS}]..." ;$off
		if sudo systemctl restart "$SERVICE"; then
			$bblue; echo "Restarted [${PROCESS}]!" ;$off
			return 0
		else
			$bred; printf "%s\n\n" "[${PROCESS}] restart failed!"; $off
			return 1
		fi
	else
		$off; echo -n "[${PROCESS}] "
		$bred; echo "not online" ;$off
	fi
}

process_Start()
{
	COMMANDS()
	{
		missing_systemd_"$NAME_FUNC"
		sudo systemctl start "$SERVICE"
	}
	process_Start_Template
}

process_Stop()
{
	COMMANDS()
	{
		$bred; echo "Stopping [${PROCESS}] gracefully..." ;$off
		sudo systemctl stop "$SERVICE" &
		for i in {1..30} ;do
			if [[ "$i" = "30" ]]; then
				echo
				print_Warn "[${PROCESS}] not responding, killing..."
				process_Kill
			fi
			if pgrep $PROCESS &>/dev/null ;then
				echo -n "."
			else
				echo "."
				break
			fi
			sleep 1
		done
	}
	process_Stop_Template
}

process_Kill()
{
	prompt_Sudo;error_Sudo
	COMMANDS()
	{
		$ired; echo "Sending kill signal to [${PROCESS}]..."
		sudo systemctl kill "$SERVICE"
	}
	process_Stop_Template
}

process_Full()
{
	case $PROCESS in
		monerod) COMMANDS(){ cd "$binMonero" ; "$binMonero/monerod" --config-file "$config/monerod.conf" ;} ;;
		xmrig) COMMANDS(){ cd "$binXMRig" ; sudo "$binXMRig/xmrig" --config "$xmrigConf" --log-file="$binXMRig/xmrig-log" ;} ;;
		p2pool)
		COMMANDS() {
			cd "$binP2Pool"
			# 2022-08-14 Backwards compatibility with
			# old [monero-bash.conf] p2pool settings.
			# WALLET
			if [[ -z $WALLET ]]; then
				if WALLET=$(grep -m 1 -E "^WALLET=(|'|\")4.*$" "$config/monero-bash.conf"); then
					WALLET=${WALLET//\'}
					WALLET=${WALLET//\"}
					WALLET=${WALLET/*=}
					print_Warn "[WALLET] not found in [p2pool.conf], falling back to [monero-bash.conf]'s [${WALLET:0:6}...${WALLET:89:95}]"
				else
					print_Warn "[WALLET] not found in [p2pool.conf]"
					print_Warn "[WALLET] not found in [monero-bash.conf]"
				fi
			fi
			# LOG_LEVEL
			if [[ -z $LOG_LEVEL ]]; then
				if LOG_LEVEL=$(grep -E "^LOG_LEVEL=(|'|\")[0-6].*$" "$config/monero-bash.conf"); then
					LOG_LEVEL=${LOG_LEVEL//\'}
					LOG_LEVEL=${LOG_LEVEL//\"}
					LOG_LEVEL=${LOG_LEVEL/*=}
					print_Warn "[LOG_LEVEL] not found in [p2pool.conf], falling back to [monero-bash.conf]'s [${LOG_LEVEL}]"
				else
					LOG_LEVEL=3
					print_Warn "[LOG_LEVEL] not found in [p2pool.conf]"
					print_Warn "[LOG_LEVEL] not found in [monero-bash.conf], falling back to [P2Pool]'s default [3]"
				fi
			fi
			# if [p2pool.conf] $DAEMON_RPC exists...
			if [[ $DAEMON_RPC ]]; then
				:
			# else, check for [monerod.conf] RPC port...
			elif DAEMON_RPC=$(grep -E "^rpc-bind-port=(|'|\")[0-9]\+$" "$config/monerod.conf"); then
				DAEMON_RPC=${DAEMON_RPC//\'}
				DAEMON_RPC=${DAEMON_RPC//\"}
				DAEMON_RPC=${DAEMON_RPC/*=}
				print_Warn "[DAEMON_RPC] not found in [p2pool.conf], falling back to [monerod.conf]'s [rpc-bind-port=$DAEMON_RPC]"
			# else, default.
			else
				DAEMON_RPC=18081
				print_Warn "[DAEMON_RPC] not found in [p2pool.conf]"
				print_Warn "[rpc-bind-port] not found in [monerod.conf], falling back to [P2Pool]'s default RPC port: [$DAEMON_RPC]"
			fi
			# same for ZMQ
			if [[ $DAEMON_ZMQ ]]; then
				:
			# else, check for [monerod.conf] ZMQ port...
			elif DAEMON_ZMQ=$(grep -E "^zmq-pub=.*:[0-9].*$" "$config/monerod.conf"); then
				DAEMON_ZMQ=${DAEMON_ZMQ/*:}
				print_Warn "[DAEMON_ZMQ] not found in [p2pool.conf], falling back to [monerod.conf]'s [zmq-pub=$DAEMON_ZMQ]"
			# else, default.
			else
				DAEMON_ZMQ=18081
				print_Warn "[DAEMON_ZMQ] not found in [p2pool.conf]"
				print_Warn "[rpc-bind-port] not found in [monerod.conf], falling back to [P2Pool]'s default ZMQ port: [$DAEMON_ZMQ]"
			fi
			# check for out/in peers
			if [[ -z $OUT_PEERS ]]; then
				OUT_PEERS=10
				print_Warn "[OUT_PEERS] not found in [p2pool.conf], falling back to [P2Pool]'s default: [$OUT_PEERS]"
			fi
			if [[ -z $IN_PEERS ]]; then
				IN_PEERS=10
				print_Warn "[IN_PEERS] not found in [p2pool.conf], falling back to [P2Pool]'s default: [$IN_PEERS]"
			fi
			# start
			"$binP2Pool/p2pool" --config $p2poolConf --out-peers $OUT_PEERS --in-peers $IN_PEERS --host "$DAEMON_IP" --rpc-port "$DAEMON_RPC" --zmq-port "$DAEMON_ZMQ" --wallet "$WALLET" --loglevel "$LOG_LEVEL"
		}
		;;
	esac
	process_Start_Template
}

process_Enable() {
	prompt_Sudo;error_Sudo
	missing_systemd_"$NAME_FUNC"
	if sudo systemctl enable "$SERVICE"; then
		$bblue; printf "%s" "[${PROCESS}] "
		$iwhite; printf "%s\n\n" "enabled, it will auto-start in the background on boot!"; $off
		return 0
	else
		$bred; printf "%s\n\n" "[${PROCESS}] enable failed!"; $off
		return 1
	fi
}

process_Disable() {
	prompt_Sudo;error_Sudo
	missing_systemd_"$NAME_FUNC"
	if sudo systemctl disable "$SERVICE"; then
		$bred; printf "%s" "[${PROCESS}] "
		$iwhite; printf "%s\n\n" "disabled, it will NOT auto-start on boot!"; $off
		return 0
	else
		$bred; printf "%s\n\n" "[${PROCESS}] disable failed!"; $off
		return 1
	fi
}
