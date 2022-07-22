# This file is part of monero-bash - a wrapper for Monero, written in Bash
#
# Copyright (c) 2022 hinto.janaiyo <https://github.com/hinto-janaiyo>
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

# create a systemd service file for packages
# assumes ask::sudo() is already triggered
systemd::create() {
	log::debug "starting systemd::create()"

	# CREATE TMP SERVICE FILE
	umask 133 || return 1
	local TMP_SERVICE SYSTEMD_USER SYSTEMD_EXEC SYSTEMD_DIRECTORY || return 2
	TMP_SERVICE=$(mktemp "/tmp/${PKG[service]}.XXXXXXXXXX")

	# CASE PACKAGES FOR UNIQUE COMMANDS
	case "${PKG[name]}" in
		monero)
			SYSTEMD_USER=monero-bash
			SYSTEMD_EXEC="monerod --config-file "$CONFIG_MONEROD" --non-interactive"
			;;
		p2pool)
			SYSTEMD_USER=monero-bash
			SYSTEMD_EXEC="$binP2Pool/p2pool --config $p2poolConf --host \$DAEMON_IP --wallet \$WALLET --loglevel \$LOG_LEVEL"
		xmrig)

# CREATE
cat << EOM >> "$TMP_SERVICE"
[Unit]
Description=${PKG[service]}
After=network-online.target
Wants=network-online.target

[Service]
User=$SYSTEMD_USER
Type=simple
EnvironmentFile=$CONFIG_MONERO_BASH
ExecStart=$SYSTEMD_EXEC
WorkingDirectory=${PKG[directory]}
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOM

	# MOVE TO SYSTEMD DIRECTORY
	sudo mv "$TMP_SERVICE" "$SYSTEMD/${PKG[service]}" || return 3

	# REMOVE TMP FILE
	rm "$TMP_SERVICE"
}
