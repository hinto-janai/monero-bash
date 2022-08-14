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
$white; echo "Creating [${SERVICE}]..."
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
EnvironmentFile=$config/monero-bash.conf
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
$white; echo "Reloading [systemd]..."
sudo systemctl daemon-reload
}

systemd_Edit()
{
	if [[ $NAME_VER = "" ]]; then
		print_Error_Exit "[${NAME_PRETTY}] is not installed"
	fi
	prompt_Sudo;error_Sudo
	if [[ -z $EDITOR ]]; then
		print_Error "No default \$EDITOR found!"
		$white; printf "Pick editor [nano, vim, emacs, etc] (default=nano): "
		read EDITOR
		[[ -z $EDITOR || $EDITOR = "default" ]] && EDITOR="nano"
	fi

	sudo "$EDITOR" "$sysd/$SERVICE"
	if [[ $? = 0 ]]; then
		$white; echo "Reloading [systemd]..."
		sudo systemctl daemon-reload
	else
		print_Error "systemd changes failed"
	fi
}

systemd_Monero()
{
	define_Monero
	local COMMAND="$binMonero/monerod --config-file "$config/monerod.conf" --non-interactive"
	systemd_Template
}

systemd_XMRig()
{
	define_XMRig
	local USER="root"
	local COMMAND="$binXMRig/xmrig --config $xmrigConf --log-file="$binXMRig/xmrig-log""
	systemd_Template
}

systemd_P2Pool()
{
	define_P2Pool
	# mini
	if [[ $MINI = true ]]; then
		local COMMAND="$binP2Pool/p2pool --config $p2poolConf --host \$DAEMON_IP --rpc-port \$DAEMON_RPC --zmq-port \$DAEMON_ZMQ --wallet \$WALLET --loglevel \$LOG_LEVEL --mini"
	else
		local COMMAND="$binP2Pool/p2pool --config $p2poolConf --host \$DAEMON_IP --rpc-port \$DAEMON_RPC --zmq-port \$DAEMON_ZMQ --wallet \$WALLET --loglevel \$LOG_LEVEL"
	fi
	systemd_Template
}

systemd_MoneroBash()
{
	echo "monero-bash: systemd not needed"
}
