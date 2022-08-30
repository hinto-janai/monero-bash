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
	[[ -z $NAME_VER ]] && print_Error_Exit "[${NAME_PRETTY}] not installed"

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
			*)
				trap 'trap_Mining; exit' 1 2 3 6 15
				echo "Skipping..."
				sudo -u "$USER" sed -i "s@.*MINE_UNCONFIGURED.*@MINE_UNCONFIGURED=false@" "$state"
				PRODUCE_HASH_LIST
				;;
		esac
	fi

	# START PROCESS IF NOT ALREADY ALIVE
	if [[ $SYSD_START = true ]]; then
		if sudo systemctl status $SERVICE &>/dev/null; then
			BRED; echo "[${PROCESS}] already detected!" ;OFF
			return 1
		fi
	elif [[ $SYSD_RESTART != true ]]; then
		if pgrep $PROCESS &>/dev/null; then
	        BRED; echo "[${PROCESS}] already detected!" ;OFF
			return 1
		fi
	fi

	missing_config_"$NAME_FUNC"

	# REFRESH LOGS
	if [[ $NAME_PRETTY = P2Pool ]]; then
		[[ -e "$binP2Pool/p2pool.log" ]] && rm "$binP2Pool/p2pool.log"
		[[ -e "$binP2Pool/local/stats" ]] && rm "$binP2Pool/local/stats"
		mkdir -p "$binP2Pool/local" "$MB_API"
		touch "$binP2Pool/p2pool.log" "$binP2Pool/local/stats"
		chmod 600 "$binP2Pool/p2pool.log" "$binP2Pool/local/stats"
		# mini state
		if [[ $MINI = true ]]; then
			echo "MINI_FLAG='--mini'" > "$MB_API/mini"
			touch "$MB_API/mini_now"
		elif [[ $MINI = false ]]; then
			echo "MINI_FLAG=" > "$MB_API/mini"
			[[ -e "$MB_API/mini_now" ]] && rm -f "$MB_API/mini_now"
		else
			echo "MINI_FLAG=" > "$MB_API/mini"
			[[ -e "$MB_API/mini_now" ]] && rm -f "$MB_API/mini_now"
			print_Warn "[MINI] not found in [p2pool.conf], falling back to [P2Pool]'s default: [false]"
		fi
		# backwards compatability (check for --stratum-api)
		if ! grep "stratum-api" "${sysd}/${SERVICE}" --quiet; then
			print_Warn "[stratum-api] option not found in [$SERVICE], stats will be inaccurate!"
			print_Warn "Consider regenerating the [${NAME_PRETTY}] systemd file: [monero-bash reset ${PROJECT} systemd]"
		fi
	elif [[ $NAME_PRETTY = XMRig && -e "$binXMRig/xmrig-log" ]]; then
		rm -rf "$binXMRig/xmrig-log"
		touch "$binXMRig/xmrig-log"
		chmod 700 "$binXMRig/xmrig-log"
	fi

	# warn against old service without security
	if ! grep "## Security Hardening" "${sysd}/${SERVICE}" --quiet; then
		print_Warn "Newer security hardening options were not found in: [${SERVICE}]"
		print_Warn "Consider regenerating the [${NAME_PRETTY}] systemd file: [monero-bash reset ${PROJECT} systemd]"
	fi

	# START/RESTART PROCESS
	COMMANDS
}

process_Start()
{
	COMMANDS() {
		prompt_Sudo;error_Sudo
		BBLUE; echo "Starting [${PROCESS}]..." ;OFF
		missing_systemd_"$NAME_FUNC"
		sudo systemctl start "$SERVICE"
	}
	local SYSD_START=true
	process_Start_Template
}

process_Restart()
{
	COMMANDS() {
		prompt_Sudo;error_Sudo
		BYELLOW; echo "Restarting [${PROCESS}]..." ;OFF
		if sudo systemctl restart "$SERVICE"; then
			BBLUE; echo "Restarted [${PROCESS}]!" ;OFF
			return 0
		else
			BRED; printf "%s\n" "[${PROCESS}] restart failed!"; OFF
			return 1
		fi
	}
	local SYSD_RESTART=true
	process_Start_Template
}

process_Stop()
{
	prompt_Sudo;error_Sudo
	local i=1
	BRED; echo "Stopping [${PROCESS}] gracefully..." ;OFF
	sudo systemctl stop "$SERVICE" &
	local SYSD_STATE=$(sudo systemctl status $SERVICE | grep -m1 "Active:")
	while [[ $SYSD_STATE != *"Active: inactive (dead)"* ]]; do
		if [[ $i = 35 ]]; then
			echo
			print_Warn "[${PROCESS}] not responding, sending SIGTERM..."
			break
		fi
		printf "%s" "."
		read -s -r -t 1
		((i++))
		local SYSD_STATE=$(sudo systemctl status $SERVICE | grep -m1 "Active:")
	done
	echo
	return 0
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
			# mini
			if [[ $MINI = true ]]; then
				MINI_FLAG="--mini"
			elif [[ $MINI = false ]]; then
				MINI_FLAG=
			else
				MINI_FLAG=
				print_Warn "[MINI] not found in [p2pool.conf], falling back to [P2Pool]'s default: [false]"
			fi
			# start
			"$binP2Pool/p2pool" --data-api $binP2Pool --stratum-api --out-peers $OUT_PEERS --in-peers $IN_PEERS --host "$DAEMON_IP" --rpc-port "$DAEMON_RPC" --zmq-port "$DAEMON_ZMQ" --wallet $WALLET --loglevel $LOG_LEVEL $MINI_FLAG
		}
		;;
	esac
	process_Start_Template
}

process_Enable() {
	prompt_Sudo;error_Sudo
	missing_systemd_"$NAME_FUNC"
	if sudo systemctl enable "$SERVICE"; then
		BBLUE; printf "%s" "[${PROCESS}] "
		IWHITE; printf "%s\n" "enabled, it will auto-start in the background on boot!"; OFF
		return 0
	else
		BRED; printf "%s\n" "[${PROCESS}] enable failed!"; OFF
		return 1
	fi
}

process_Disable() {
	prompt_Sudo;error_Sudo
	missing_systemd_"$NAME_FUNC"
	if sudo systemctl disable "$SERVICE"; then
		BRED; printf "%s" "[${PROCESS}] "
		IWHITE; printf "%s\n" "disabled, it will NOT auto-start on boot!"; OFF
		return 0
	else
		BRED; printf "%s\n" "[${PROCESS}] disable failed!"; OFF
		return 1
	fi
}
