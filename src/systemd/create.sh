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
	log::debug "starting ${FUNCNAME}() for: ${PKG[pretty]}"

	# CREATE TMP SERVICE FILE
	local TMP_SERVICE SYSTEMD_USER SYSTEMD_EXEC SYSTEMD_DIRECTORY || return 2
	TMP_SERVICE=$(mktemp "/tmp/${PKG[service]}.XXXXXXXXXX")
	chmod 660 "$TMP_SERVICE"

	# CASE PACKAGES FOR UNIQUE COMMANDS
	case "${PKG[name]}" in
		monero)
			SYSTEMD_USER=monero-bash
			SYSTEMD_ENV="$CONFIG_MONERO_BASH"
			SYSTEMD_EXEC="${PKG[directory]}/monerod --config-file $CONFIG_MONEROD --non-interactive"
			;;
		p2pool)
			SYSTEMD_USER=monero-bash
			SYSTEMD_ENV="$CONFIG_P2POOL"
			SYSTEMD_EXEC="${PKG[directory]}/p2pool --wallet \$P2POOL_WALLET"
			;;
		xmrig)
			SYSTEMD_USER=root
			SYSTEMD_ENV=""
			SYSTEMD_EXEC="${PKG[directory]}/xmrig --config $CONFIG_XMRIG --log-file=$PKG_XMRIG/xmrig.log"
			;;
	esac

# CREATE
cat << EOM >> "$TMP_SERVICE"
[Unit]
Description=${PKG[service]}
After=network-online.target
Wants=network-online.target

[Service]
User=$SYSTEMD_USER
Type=simple
EnvironmentFile="$SYSTEMD_ENV"
ExecStart=$SYSTEMD_EXEC
WorkingDirectory=${PKG[directory]}
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOM

	# MOVE TO MONERO-BASH SYSTEMD DIRECTORY
	mkdir -p "$DOT_SYSD"
	mv "$TMP_SERVICE" "$DOT_SYSD/${PKG[service]}"

	# PERMISSIONS
	sudo chown -R monero-bash:"$USER" "$TMP_SERVICE"

	# CREATE SYMLINK TO /etc/systemd/system
	sudo ln -s "$DOT_SYSD/${PKG[service]}" "$SYSTEMD/${PKG[service]}"
}
