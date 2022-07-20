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

# uninstall for monero-bash
monero_bash::uninstall() {

log::debug "starting monero_bash::uninstall()"

# TITLE
printf "${BWHITE}%s\n${BWHITE}%s${BRED}%s${BWHITE}%s\n${BWHITE}%s${OFF}\n" \
	"@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" \
	"@ " \
	"THIS WILL UNINSTALL [monero-bash], DELETE /.monero-bash/ AND EVERYTHING INSIDE IT " \
	"@" \
	"@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
print::size

# PROMPT
printf "${BWHITE}%s${BRED}%s${BWHITE}%s${OFF}" \
	"Uninstall " \
	"[monero-bash]" \
	"?"
if ! ask::yes; then
	print::exit "Canceling [monero-bash] uninstall"
fi

# WARN USER IF WALLETS FOUND
local WALLET_COUNT
WALLET_COUNT=$(ls "$WALLETS" | wc -l) || exit 1
if [[ $WALLET_COUNT != 0 ]]; then
	printf "${BWHITE}%s\n${BWHITE}%s${BRED}%s${BWHITE}%s\n${BWHITE}%s\n${BRED}%s" \
		"@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" \
		"@ " \
		"         WARNING: WALLETS FOUND          " \
		"@" \
		"@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" \
		"ARE YOU SURE YOU WANT TO UNINSTALL? (y/N) "
	if ask::no; then
		exit 1
	fi
fi

# SUDO
if ! ask::sudo; then
	print::exit "sudo is needed to uninstall"
fi

# 10 SECOND COUNTDOWN
local i
for i in {10..0}; do
	printf "\r\e[2K${BYELLOW}%s" "Uninstalling in ${i}..."
	sleep 1
done

# STOP ALL PROCESSES
log::info "stopping all processes"
if [[ $MONERO_VER ]]; then
	if systemctl status monero-bash-monerod &>/dev/null; then
		process::systemd::stop monerod
	fi
fi
if [[ $P2POOL_VER ]]; then
	if systemctl status monero-bash-p2pool &>/dev/null; then
		process::systemd::stop p2pool
	fi
fi
if [[ $XMRIG_VER ]]; then
	if systemctl status monero-bash-xmrig &>/dev/null; then
		process::systemd::stop xmrig
	fi
fi

# REMOVAL
trap "" INT
___BEGIN___ERROR___TRACE___
log::prog "Removing $DOT"
rm -rf "$DOT"
log::ok "Removed $DOT"

log::prog "Removing from PATH"
sudo rm /usr/local/bin/monero-bash
[[ -e /usr/local/bin/mb ]] && sudo rm /usr/local/bin/monero-bash
log::ok "Removed from PATH"

log::prog "Removing systemd services"
[[ -e "$SYSTEMD/monero-bash-monerod.service" ]] && sudo rm "$SYSTEMD/monero-bash-monerod.service"
[[ -e "$SYSTEMD/monero-bash-p2pool.service" ]] && sudo rm "$SYSTEMD/monero-bash-p2pool.service"
[[ -e "$SYSTEMD/monero-bash-xmrig.service" ]] && sudo rm "$SYSTEMD/monero-bash-xmrig.service"
log::ok "Removed systemd services"
___ENDOF___ERROR___TRACE___

# END
echo
log::ok "Successfully uninstalled [monero-bash]"
exit 0
}










































