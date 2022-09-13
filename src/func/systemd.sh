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


# functions FOR CREATING systemd .service files

systemd_Template()
{
OFF; echo "Creating [${SERVICE}]..."
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
After=network-online.target
StartLimitIntervalSec=300
StartLimitBurst=5

[Service]
## Basics
User=$USER
Group=$USER
Type=simple

## Environment
$ENV_FILE
$ENV_LINE

## Start
ExecStart=$COMMAND
WorkingDirectory=$DIRECTORY

## Stop/Restart
KillSignal=SIGINT
Restart=on-failure
RestartSec=5s

## Open file limit
$FILE_LIMIT

## Wait 1 minute before sending SIGKILL
TimeoutStopSec=60s
SendSIGKILL=true

## Security Hardening
## If this service isn't working well (low hashrate, can't connect)
## you might want to disable some (or all) of the settings below:
CapabilityBoundingSet=~CAP_NET_ADMIN CAP_SYS_PTRACE CAP_SYS_ADMIN CAP_KILL CAP_SYS_PACCT CAP_SYS_BOOT CAP_SYS_CHROOT CAP_LEASE CAP_MKNOD CAP_CHOWN CAP_FSETID CAP_SETFCAP CAP_SETUID CAP_SETGID CAP_SETPCAP CAP_SYS_TIME CAP_IPC_LOCK CAP_LINUX_IMMUTABLE CAP_FOWNER CAP_IPC_OWNER CAP_SYS_RESOURCE CAP_SYS_NICE
$PROTECT_PROC
$PROC_SUBSET
$PROTECT_CONTROL_GROUPS
$PROTECT_HOSTNAME
$PROTECT_CLOCK
$PROTECT_KERNEL_MODULES
$PROTECT_KERNEL_LOGS
$PROTECT_KERNEL_TUNABLES
$RESTRICT_REAL_TIME
$RESTRICT_NAMESPACES
$PRIVATE_USERS
## These ones shouldn't affect performance and
## probably should be left on for security reasons.
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=read-only
$BIND_PATHS

[Install]
WantedBy=multi-user.target
EOM

# INSTALL SERVICE IN /etc/systemd/system/
sudo chmod -R 600 "$tmpService"
sudo mv -f "$tmpService/$SERVICE" "$sysd"
sudo rm -r "$tmpService"
permission_Systemd

# RELOAD SYSTEMD
OFF; echo "Reloading [systemd]..."
sudo systemctl daemon-reload
}

systemd_Monero()
{
	local COMMAND ENV_FILE ENV_LINE FILE_LIMIT BIND_PATHS CAPABILITY_BOUNDING_SET PROTECT_CLOCK PROTECT_KERNEL_MODULES DATA_DIR PROTECT_KERNEL_TUNABLES PRIVATE_USERS PROTECT_KERNEL_LOGS PROTECT_PROC PROTECT_CONTROL_GROUPS RESTRICT_REAL_TIME RESTRICT_NAMESPACES PROTECT_HOSTNAME PROC_SUBSET
	COMMAND="$binMonero/monerod --config-file $config/monerod.conf --non-interactive"
	ENV_FILE="#EnvironmentFile= #none"
	ENV_LINE="#EnvironmentFile= #none"
	FILE_LIMIT="LimitNOFILE=16384"
	PROTECT_CLOCK="ProtectClock=true"
	PROTECT_KERNEL_MODULES="ProtectKernelModules=true"
	PROTECT_KERNEL_TUNABLES="ProtectKernelTunables=true"
	PRIVATE_USERS="PrivateUsers=true"
	PROTECT_KERNEL_LOGS="ProtectKernelLogs=true"
	case "$(hostnamectl | grep "Operating System")" in
		*Arch*|*Fedora*|*Gentoo*) PROTECT_PROC="ProtectProc=invisible" PROC_SUBSET="ProcSubset=pid";;
		*) PROTECT_PROC="#ProtectProc=invisible #Disabled on Debian-based distros (systemd version too old)" PROC_SUBSET="#ProcSubset=pid #Disabled on Debian-based distros (systemd version too old)";;
	esac
	PROTECT_CONTROL_GROUPS="ProtectControlGroups=true"
	RESTRICT_REAL_TIME="RestrictRealtime=true"
	RESTRICT_NAMESPACES="RestrictNamespaces=true"
	PROTECT_HOSTNAME="ProtectHostname=true"

	define_Monero
	if ! DATA_DIR=$(grep "^data-dir=/.*$" $config/monerod.conf); then
		DATA_DIR="$HOME/.bitmonero"
		print_Warn "[data-dir] not found in [monerod.conf], falling back to [Monero]'s default: [$HOME/.bitmonero]"
	fi
	BIND_PATHS="BindPaths=$binMonero ${DATA_DIR/*=}"
	systemd_Template
}

systemd_XMRig()
{
	local USER COMMAND ENV_FILE ENV_LINE FILE_LIMIT BIND_PATHS CAPABILITY_BOUNDING_SET PROTECT_CLOCK PROTECT_KERNEL_MODULES PROTECT_KERNEL_TUNABLES PRIVATE_USERS PROTECT_KERNEL_LOGS PROTECT_PROC PROTECT_CONTROL_GROUPS RESTRICT_REAL_TIME RESTRICT_NAMESPACES PROTECT_HOSTNAME PROC_SUBSET
	COMMAND="$binXMRig/xmrig --config $xmrigConf --log-file=$binXMRig/xmrig-log"
	USER="root"
	ENV_FILE="#EnvironmentFile= #none"
	ENV_LINE="#EnvironmentFile= #none"
	FILE_LIMIT="#LimitNOFILE=4096 #Disabled for XMRig"
	PROTECT_CLOCK="#ProtectClock=true #Disabled for XMRig"
	PROTECT_KERNEL_MODULES="#ProtectKernelModules=true #Disabled for XMRig"
	PROTECT_KERNEL_TUNABLES="#ProtectKernelTunables=true #Disabled for XMRig"
	PRIVATE_USERS="#PrivateUsers=true #Disabled for XMRig"
	BIND_PATHS="BindPaths=$binXMRig $xmrigConf"
	PROTECT_KERNEL_LOGS="#ProtectKernelLogs=true #Disabled for XMRig"
	case "$(hostnamectl | grep "Operating System")" in
		*Arch*|*Fedora*|*Gentoo*) PROTECT_PROC="ProtectProc=invisible" PROC_SUBSET="ProcSubset=pid";;
		*) PROTECT_PROC="#ProtectProc=invisible #Disabled on Debian-based distros (systemd version too old)" PROC_SUBSET="#ProcSubset=pid #Disabled on Debian-based distros (systemd version too old)";;
	esac
	PROTECT_CONTROL_GROUPS="ProtectControlGroups=true"
	RESTRICT_REAL_TIME="#RestrictRealtime=true #Disabled for XMRig"
	RESTRICT_NAMESPACES="#RestrictNamespaces=true #Disabled for XMRig"
	PROTECT_HOSTNAME="#ProtectHostname=true #Disabled for XMRig"
	# Debian's [systemd] is old as hell and
	# still has a bug that prevents this
	# option being used correctly. It stops
	# XMRig from launching so, disable it
	# only on Debian machines.
#	if [[ $(uname -a) = *Debian* ]]; then
#		print_Warn "Debian detected: systemd's [ProcSubset] will be DISABLED for XMRig to prevent a Debian-specific bug"
#		PROC_SUBSET="#ProcSubset=pid #This machine was detected as Debian. This option is disabled to avoid a Debian-specific bug."
#	else
#		PROC_SUBSET="ProcSubset=pid"
#	fi
	# [2022-09-02 Update]
	# Setting 'BindReadOnlyPaths=/proc' fixes this
	define_XMRig
	systemd_Template
}

systemd_P2Pool()
{
	local COMMAND ENV_FILE ENV_LINE FILE_LIMIT BIND_PATHS CAPABILITY_BOUNDING_SET PROTECT_CLOCK PROTECT_KERNEL_MODULES PROTECT_KERNEL_TUNABLES PRIVATE_USERS PROTECT_KERNEL_LOGS PROTECT_PROC PROTECT_CONTROL_GROUPS RESTRICT_REAL_TIME RESTRICT_NAMESPACES PROTECT_HOSTNAME PROC_SUBSET
	COMMAND="$binP2Pool/p2pool --data-api $binP2Pool --stratum-api --host \$DAEMON_IP --wallet \$WALLET --loglevel \$LOG_LEVEL \$MINI_FLAG"
	ENV_FILE="EnvironmentFile=$config/p2pool.conf"
	ENV_LINE="EnvironmentFile=$MB_API/mini"
	FILE_LIMIT="LimitNOFILE=16384"
	CAPABILITY_BOUNDING_SET="CapabilityBoundingSet="
	PROTECT_CLOCK="ProtectClock=true"
	PROTECT_KERNEL_MODULES="ProtectKernelModules=true"
	PROTECT_KERNEL_TUNABLES="ProtectKernelTunables=true"
	PRIVATE_USERS="PrivateUsers=true"
	BIND_PATHS="BindPaths=$binP2Pool"
	PROTECT_KERNEL_LOGS="ProtectKernelLogs=true"
	case "$(hostnamectl | grep "Operating System")" in
		*Arch*|*Fedora*|*Gentoo*) PROTECT_PROC="ProtectProc=invisible" PROC_SUBSET="ProcSubset=pid";;
		*) PROTECT_PROC="#ProtectProc=invisible #Disabled on Debian-based distros (systemd version too old)" PROC_SUBSET="#ProcSubset=pid #Disabled on Debian-based distros (systemd version too old)";;
	esac
	PROTECT_CONTROL_GROUPS="ProtectControlGroups=true"
	RESTRICT_REAL_TIME="RestrictRealtime=true"
	RESTRICT_NAMESPACES="RestrictNamespaces=true"
	PROTECT_HOSTNAME="ProtectHostname=true"
	define_P2Pool
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
	elif DAEMON_RPC=$(grep -E "^rpc-bind-port=(|'|\")[0-9]\+$" "$config/monerod.conf"); then
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
	elif DAEMON_ZMQ=$(grep -E "^zmq-pub=.*:[0-9].*$" "$config/monerod.conf"); then
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
	if [[ $MINI = true ]]; then
		echo "MINI_FLAG='--mini'" > "$MB_API/mini"
	elif [[ $MINI = false ]]; then
		echo "MINI_FLAG=" > "$MB_API/mini"
	else
		echo "MINI_FLAG=" > "$MB_API/mini"
		print_Warn "[MINI] not found in [p2pool.conf], falling back to [P2Pool]'s default: [false]"
	fi
	systemd_Template
}

systemd_MoneroBash()
{
	echo "monero-bash: systemd not needed"
}
