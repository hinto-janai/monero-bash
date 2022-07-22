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

# for resetting config files and systemd services
process::reset_files() {
	log::debug "starting process::reset_files"

	# CHECK IF PACKAGE IS INSTALLED
	if [[ -z ${PKG[version]} ]]; then
		print::exit "${PKG[pretty]} is not installed"
	fi

	# CASE PACKAGE
	case "${PKG[name]}" in
		*bash*)
			printf "${BWHITE}%s${BRED}%s${BWHITE}%s${OFF}\n" \
				"This will overwrite your current " \
				"[${PKG[pretty]}] " \
				"config with a new default version"
			;;
		*)
			printf "${BWHITE}%s${BRED}%s${BWHITE}%s${OFF}\n" \
				"This will overwrite your current " \
				"[${PKG[pretty]}] " \
				"config & systemd service files with new default versions"
			;;
	esac

	# PROMPT
	printf "${BWHITE}%s${OFF}" "Continue? (y/N) "
	if ask::no; then
		print::exit "Canceling reset"
	fi

	# SUDO
	if ! ask::sudo; then
		print::exit "sudo is required"
	fi

	# CASE PACKAGE FOR RESET
	case "${PKG[name]}" in
		*bash*)
			cp -f "$PKG_MONERO_BASH/config/monero-bash.conf" "$CONFIG"
			;;
		monero)
			cp -f "$PKG_MONERO_BASH/config/monerod.conf" "$CONFIG"
			cp -f "$PKG_MONERO_BASH/config/monero-wallet-cli.conf" "$CONFIG"
			systemd::create
			systemd::reload
			;;
		p2pool)
			cp -f "$PKG_MONERO_BASH/config/p2pool.conf" "$CONFIG"
			systemd::create
			systemd::reload
			;;
		xmrig)
			cp -f "$PKG_MONERO_BASH/config/xmrig.json" "$CONFIG"
			systemd::create
			systemd::reload
			;;
	esac
	return 0
}
