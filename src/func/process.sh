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
		printf "%s\n"
			"First time [P2Pool] detected!"
			"Would you like to enter configure mode? (Y/n) "
		local YES_NO
		read YES_NO
		case $YES_NO in
			y|Y|yes|Yes|YES|"") mine_Config;;
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
		$white; echo -n "[${PROCESS}] "
		$bred; echo "not online" ;$off
	fi
}

process_Restart()
{
	prompt_Sudo;error_Sudo
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
		$white; echo -n "[${PROCESS}] "
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
				print_Error "[${PROCESS}] not responding, killing..."
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
			# if [monero-bash.conf] $DAEMON_RPC exists...
			if [[ $DAEMON_RPC ]]; then
				:
			# else, check for [monerod.conf] RPC port...
			elif DAEMON_RPC=$(grep "^rpc-bind-port=.*$" "$config/monerod.conf"); then
				DAEMON_RPC=${DAEMON_RPC/*=}
				print_Error "[DAEMON_RPC] not found in [monero-bash.conf]"
				print_Error "Falling back to [monerod.conf]'s [rpc-bind-port=$DAEMON_RPC]"
			# else, default.
			else
				DAEMON_RPC=18081
				print_Error "[DAEMON_RPC] not found in [monero-bash.conf]"
				print_Error "[rpc-bind-port] not found in [monerod.conf]"
				print_Error "Falling back to [P2Pool]'s default RPC port: [$DAEMON_RPC]"
			fi
			# same for ZMQ
			if [[ $DAEMON_ZMQ ]]; then
				:
			elif DAEMON_ZMQ=$(grep "^zmq-pub=.*$" "$config/monerod.conf"); then
				DAEMON_ZMQ=${DAEMON_ZMQ/*=}
				print_Error "[DAEMON_ZMQ] not found in [monero-bash.conf]"
				print_Error "Falling back to [monerod.conf]'s [rpc-bind-port=$DAEMON_RPC]"
			else
				DAEMON_ZMQ=18083
				print_Error "[DAEMON_RPC] not found in [monero-bash.conf]"
				print_Error "[zmq-pub] not found in [monerod.conf]"
				print_Error "Falling back to [P2Pool]'s default ZMQ port: [$DAEMON_ZMQ]"
			fi
			# start
			"$binP2Pool/p2pool" --config $p2poolConf --host "$DAEMON_IP" --rpc-port "$DAEMON_RPC" --zmq-port "$DAEMON_ZMQ" --wallet "$WALLET" --loglevel "$LOG_LEVEL"
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
