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


# functions FOR CREATING systemd .service files

systemd_Template()
{
$off; echo "Creating [${SERVICE}]..."
prompt_Sudo
error_Sudo

# DELETE PREVIOUS SERVICES IF FOUND
if find /tmp/monero-bash-service.* &>/dev/null ; then
    rm -rf /tmp/monero-bash-service.*
fi

# MAKE 600 PERMISSION TMP FOLDER
mktemp -d /tmp/monero-bash-service.XXXXXXXXXX &>/dev/null
tmpService="$(find /tmp/monero-bash-service.*)"

# CREATE SERVICE FILE
cat > $tmpService/$SERVICE <<EOM
[Unit]
Description=$SERVICE
After=network.target

[Service]
User=$USER
Group=$USER
Type=simple
$ENV_FILE
ExecStart=$COMMAND
WorkingDirectory=$DIRECTORY
Restart=always

[Install]
WantedBy=multi-user.target
EOM

# INSTALL SERVICE IN /etc/systemd/system/
sudo chmod -R 600 "$tmpService"
sudo mv -f "$tmpService/$SERVICE" "$sysd"
sudo rm -r "$tmpService"
permission_Systemd

# RELOAD SYSTEMD
$off; echo "Reloading [systemd]..."
sudo systemctl daemon-reload
}

systemd_Edit()
{
	if [[ $NAME_VER = "" ]]; then
		print_Error_Exit "[${NAME_PRETTY}] is not installed"
	fi
	prompt_Sudo;error_Sudo
	if [[ -z $EDITOR ]]; then
		print_Warn "No default \$EDITOR found!"
		$off; printf "Pick editor [nano, vim, emacs, etc] (default=nano): "
		read EDITOR
		[[ -z $EDITOR || $EDITOR = "default" ]] && EDITOR="nano"
	fi

	sudo "$EDITOR" "$sysd/$SERVICE"
	if [[ $? = 0 ]]; then
		$off; echo "Reloading [systemd]..."
		sudo systemctl daemon-reload
	else
		print_Error "systemd changes failed"
	fi
}

systemd_Monero()
{
	define_Monero
	local COMMAND="$binMonero/monerod --config-file $config/monerod.conf --non-interactive"
	systemd_Template
}

systemd_XMRig()
{
	define_XMRig
	local USER="root"
	local COMMAND="$binXMRig/xmrig --config $xmrigConf --log-file=$binXMRig/xmrig-log"
	systemd_Template
}

systemd_P2Pool()
{
	define_P2Pool
	local COMMAND="$binP2Pool/p2pool --config $p2poolConf --host \$DAEMON_IP --wallet \$WALLET --loglevel \$LOG_LEVEL"
	# 2022-08-14 Backwards compatibility with
	# old [monero-bash.conf] p2pool settings.
	# WALLET
	# (only if not installing for first time)
	if [[ -z $WALLET && -z $INSTALL ]]; then
		if [[ $INSTALL ]]; then
			print_Warn "[WALLET] not found in [p2pool.conf], falling back to [monero-bash.conf]'s [${WALLET:0:6}...${WALLET:89:95}]"
		elif WALLET=$(grep -E "^WALLET=(|'|\")4.*$" "$config/monero-bash.conf"); then
			WALLET=${WALLET//\'}
			WALLET=${WALLET//\"}
			WALLET=${WALLET/*=}
			COMMAND="$COMMAND --wallet $WALLET"
			print_Warn "[WALLET] not found in [p2pool.conf], falling back to [monero-bash.conf]'s [${WALLET:0:6}...${WALLET:89:95}]"
		else
			print_Warn "[WALLET] not found in [p2pool.conf]"
			print_Warn "[WALLET] not found in [monero-bash.conf]"
		fi
	fi
	# LOG LEVEL
	if [[ -z $LOG_LEVEL && -z $INSTALL ]]; then
		if LOG_LEVEL=$(grep -E "^LOG_LEVEL=(|'|\")[0-6].*$" "$config/monero-bash.conf"); then
			LOG_LEVEL=${LOG_LEVEL//\'}
			LOG_LEVEL=${LOG_LEVEL//\"}
			LOG_LEVEL=${LOG_LEVEL/*=}
			COMMAND="$COMMAND --loglevel $LOG_LEVEL"
			print_Warn "[LOG_LEVEL] not found in [p2pool.conf], falling back to [monero-bash.conf]'s [${LOG_LEVEL}]"
		else
			LOG_LEVEL=3
			COMMAND="$COMMAND --log-level $LOG_LEVEL"
			print_Warn "[LOG_LEVEL] not found in [p2pool.conf]"
			print_Warn "[LOG_LEVEL] not found in [monero-bash.conf], falling back to [P2Pool]'s default [3]"
		fi
	fi
	# if [p2pool.conf] $DAEMON_RPC exists...
	if [[ $DAEMON_RPC || $INSTALL ]]; then
		COMMAND="$COMMAND --rpc-port \$DAEMON_RPC"
	# else, check for [monerod.conf] RPC port...
	elif DAEMON_RPC=$(grep "^rpc-bind-port=.*$" "$config/monerod.conf"); then
		DAEMON_RPC=${DAEMON_RPC//\'}
		DAEMON_RPC=${DAEMON_RPC//\"}
		DAEMON_RPC=${DAEMON_RPC//*=}
		COMMAND="$COMMAND --rpc-port $DAEMON_RPC"
		print_Warn "[DAEMON_RPC] not found in [p2pool.conf], falling back to [monerod.conf]'s [rpc-bind-port=$DAEMON_RPC]"
	# else, default.
	else
		DAEMON_RPC=18081
		COMMAND="$COMMAND --rpc-port $DAEMON_RPC"
		print_Warn "[DAEMON_RPC] not found in [p2pool.conf]"
		print_Warn "[rpc-bind-port] not found in [monerod.conf], falling back to [P2Pool]'s default RPC port: [$DAEMON_RPC]"
	fi
	# same for ZMQ
	if [[ $DAEMON_ZMQ || $INSTALL ]]; then
		COMMAND="$COMMAND --zmq-port \$DAEMON_ZMQ"
	elif DAEMON_ZMQ=$(grep "^zmq-pub=.*$" "$config/monerod.conf"); then
		DAEMON_ZMQ=${DAEMON_ZMQ//\'}
		DAEMON_ZMQ=${DAEMON_ZMQ//\"}
		DAEMON_ZMQ=${DAEMON_ZMQ//*:}
		COMMAND="$COMMAND --zmq-port $DAEMON_ZMQ"
		print_Warn "[DAEMON_ZMQ] not found in [p2pool.conf], falling back to [monerod.conf]'s [rpc-bind-port=$DAEMON_ZMQ]"
	else
		DAEMON_ZMQ=18083
		COMMAND="$COMMAND --zmq-port $DAEMON_ZMQ"
		print_Warn "[DAEMON_RPC] not found in [p2pool.conf]"
		print_Warn "[zmq-pub] not found in [monerod.conf], falling back to [P2Pool]'s default ZMQ port: [$DAEMON_ZMQ]"
	fi
	# check for out/in peers
	if [[ $OUT_PEERS || $INSTALL ]]; then
		COMMAND="$COMMAND --out-peers \$OUT_PEERS"
	else
		OUT_PEERS=10
		COMMAND="$COMMAND --out-peers $OUT_PEERS"
		print_Warn "[OUT_PEERS] not found in [p2pool.conf], falling back to [P2Pool]'s default: [$OUT_PEERS]"
	fi
	if [[ $IN_PEERS || $INSTALL ]]; then
		COMMAND="$COMMAND --in-peers \$IN_PEERS"
	else
		IN_PEERS=10
		COMMAND="$COMMAND --in-peers $IN_PEERS"
		print_Warn "[IN_PEERS] not found in [p2pool.conf], falling back to [P2Pool]'s default: [$IN_PEERS]"
	fi
	# mini
	[[ $MINI = true ]] && COMMAND="$COMMAND --mini"
	local ENV_FILE="EnvironmentFile=$config/p2pool.conf"
	systemd_Template
}

systemd_MoneroBash()
{
	echo "monero-bash: systemd not needed"
}
