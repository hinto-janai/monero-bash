# This is a slightly modified version of [torsocks v2.3.0] from
# the Debian APT repositories for specific use in [monero-bash].
# Some changes:
#     - Remove macOS code
#     - Remove interactive options
#     - Remove some features (Tor shell, etc)
#     - Remove the [realpath] lib that was originally used (https://github.com/mkropat/sh-realpath)
#     - Add [libtorsocks.so] checks
#     - Add [libtorsocks.so] backup (monero-bash/src/libtorsocks.so)
#     - Transform to a function() instead of a script.sh
#

#-------------------------------------------------------------------------------- BEGIN ORIGINAL TORSOCKS SOURCE
# ***************************************************************************
# *                                                                         *
# *                                                                         *
# *   Copyright (C) 2008 by Robert Hogan                                    *
# *   robert@roberthogan.net                                                *
# *   Copyright (C) 2012 by Jacob Appelbaum <jacob@torproject.org>          *
# *   Copyright (C) 2013 by David Goulet <dgoulet@ev0ke.net>                *
# *                                                                         *
# *   This program is free software; you can redistribute it and/or modify  *
# *   it under the terms of the GNU General Public License as published by  *
# *   the Free Software Foundation; either version 2 of the License, or     *
# *   (at your option) any later version.                                   *
# *                                                                         *
# *   This program is distributed in the hope that it will be useful,       *
# *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
# *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
# *   GNU General Public License for more details.                          *
# *                                                                         *
# *   You should have received a copy of the GNU General Public License     *
# *   along with this program; if not, write to the                         *
# *   Free Software Foundation, Inc.,                                       *
# *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
# ***************************************************************************
# *                                                                         *
# *   This is a modified version of a source file from the Tor project.     *
# *   Original copyright information follows:                               *
# ***************************************************************************
# Wrapper script for use of the torsocks(8) transparent socksification library
#
# There are three forms of usage for this script:
#
# /usr/bin/torsocks program [program arguments...]
#
# This form sets the users LD_PRELOAD environment variable so that torsocks(8)
# will be loaded to socksify the application then executes the specified
# program (with the provided arguments). The following simple example might
# be used to ssh to www.foo.org via a torsocks.conf(5) configured socks server:
#
# /usr/bin/torsocks ssh www.foo.org
#
# The second form allows for torsocks(8) to be switched on and off for a
# session (that is, it adds and removes torsocks from the LD_PRELOAD environment
# variable). This form must be _sourced_ into the user's existing session
# (and will only work with bourne shell users):
#
# . /usr/bin/torsocks on
# telnet www.foo.org
# . /usr/bin/torsocks off
#
# Or
#
# source /usr/bin/torsocks on
# telnet www.foo.org
# source /usr/bin/torsocks off
#
# This script is originally from the debian torsocks package by
# Tamas Szerb <toma@rulez.org>
# Modified by Robert Hogan <robert@roberthogan.net> April 16th 2006
# Modified by David Goulet <dgoulet@ev0ke.net> 2013
# Modified by Alex Xu (Hello71) <alex_y_xu@yahoo.ca> 2018

# Set LD_PRELOAD variable with torsocks library path.
set_ld_preload()
{
	case "$LD_PRELOAD" in
		*"${SHLIB}"*) ;;
		'')
			export LD_PRELOAD="${SHLIB}"
			;;
		*)
			export LD_PRELOAD="${SHLIB}:$LD_PRELOAD"
			;;
	esac
}

torify_app()
{
	local app_path="$(command -v "$1")" || { print_Error "Torsocks error 1"; exit 1; }
	local getcap="$(PATH="$PATH:/usr/sbin:/sbin" command -v getcap)" || { print_Error "Torsocks error 2"; exit 2; }
	local caps= || { print_Error "Torsocks error 3"; exit 3; }

	if [ -z "$1" ]; then
		echo "Please provide an application to torify."
		exit 4
	elif [ -z "$app_path" ]; then
		echo "ERROR: $1 cannot be found."
		exit 5
	fi

	# This must be before torifying because getcap uses cap_get_file(3)
	# via syscall(2) which breaks torsocks.
	if [ -n "$getcap" ]; then
		caps="$("$getcap" "$app_path" 2>/dev/null)" || { print_Error "Torsocks error 6"; exit 6; }
	fi

	# NEVER remove that line or else nothing it torified.
	set_ld_preload

	if [ -u "$app_path" ]; then
		echo "ERROR: $1 is setuid. torsocks will not work on a setuid executable."
		{ print_Error "Torsocks error 7"; exit 7; }
	elif [ -g "$app_path" ]; then
		echo "ERROR: $1 is setgid. torsocks will not work on a setgid executable."
		{ print_Error "Torsocks error 8"; exit 8; }
	elif [ -n "$caps" ]; then
		printf "ERROR: %s gains the following elevated capabilities. torsocks will not work with privileged executables.\n%s" "$app_path" "$caps"
		{ print_Error "Torsocks error 9"; exit 9; }
	fi

	"$@" || { print_Error "Torsocks error 10"; exit 10; }
	unset -v LD_PRELOAD || { print_Error "Torsocks error 11"; exit 11; }
}

#-------------------------------------------------------------------------------- BEGIN [MONERO-BASH] MODIFICATIONS
# Initialize some beginning values for Tor
torsocks_init() {
	[[ $TORSOCKS_INIT = ___SET___ ]] && return 0

	[[ $TOR_QUIET = true ]] || printf "${BWHITE}${UWHITE}%s${BPURPLE}%s${OFF}\n" "Routing through " "Tor [${TOR_PROXY}]"

	# Check if [libtorsocks.so] exists (Arch Linux)
	[[ $TOR_QUIET = true ]] || { [[ $TEST_TOR = true ]] && log::prog "[1/6] libtorsocks.so" || log::prog "libtorsocks.so"; }
	if [[ -e /usr/lib/torsocks/libtorsocks.so ]]; then
		declare -g SHLIB="/usr/lib/torsocks/libtorsocks.so" || { print_Error "Torsocks error 12"; exit 12; }
		[[ $TOR_QUIET = true ]] || { [[ $TEST_TOR = true ]] && log::ok "[1/6] libtorsocks.so -> system" || log::ok "libtorsocks.so -> system"; }
	# For Debian
	elif [[ -e /usr/lib/x86_64-linux-gnu/torsocks/libtorsocks.so ]]; then
		declare -g SHLIB="/usr/lib/x86_64-linux-gnu/torsocks/libtorsocks.so" || { print_Error "Torsocks error 13"; exit 13; }
		[[ $TOR_QUIET = true ]] || { [[ $TEST_TOR = true ]] && log::ok "[1/6] libtorsocks.so -> system" || log::ok "libtorsocks.so -> system"; }
	# [monero-bash] builtin version
	elif [[ -e /usr/local/share/monero-bash/src/libtorsocks.so ]]; then
		declare -g SHLIB="/usr/local/share/monero-bash/src/libtorsocks.so" || { print_Error "Torsocks error 14"; exit 14; }
		[[ $TOR_QUIET = true ]] || { [[ $TEST_TOR = true ]] && log::ok "[1/6] libtorsocks.so -> system" || log::ok "libtorsocks.so -> system"; }
	else
		log::fail "[1/6] libtorsocks.so -> no system or builtin found" || log::fail "libtorsocks.so -> no system or builtin found"
		exit 15
	fi

	# Test Tor (if enabled)
	if [[ $TEST_TOR = true ]]; then
		# check systemd service
		[[ $TOR_QUIET = true ]] || log::prog "[2/6] <tor.service>"
		if [[ $TOR_IP = 127.0.0.1 || $TOR_IP = localhost ]]; then
			if systemctl status tor.service &>/dev/null; then
				[[ $TOR_QUIET = true ]] || log::ok "[2/6] <tor.service>"
			else
				log::fail "[2/6] <tor.service> not online"
				exit 16
			fi
		else
			[[ $TOR_QUIET = true ]] || log::warn "[2/6] Non-local Tor detected, skipping systemd check"
		fi
		# check wget response (Tor is not an HTTP Proxy)
		[[ $TOR_QUIET = true ]] || log::prog "[3/6] SOCKS Proxy"
		case "$TOR_IP" in
			localhost|127.0.0.1|192.168.*) local TOR_WGET_TEST="$(wget -O- "$TOR_PROXY" 2>&1)";;
			*) local TOR_WGET_TEST="$(torsocks_func wget -O- "$TOR_PROXY" 2>&1)";;
		esac
		# test tor proxy reponse
		case "$TOR_WGET_TEST" in
			*"Tor is not an HTTP Proxy"*|*"SOCKS Proxy"*|*"SOCKs proxy"*) [[ $TOR_QUIET = true ]] || log::ok "[3/6] SOCKS Proxy";;
			*) log::fail "[3/6] SOCKS Proxy not detected"; exit 17;;
		esac
		# check [https://check.torproject.org]
		[[ $TOR_QUIET = true ]] || log::prog "[4/6] <check.torproject.org>"
		local CHECK_TORPROJECT || exit 18
		if CHECK_TORPROJECT=$(torsocks_func wget "${WGET_HTTP_HEADERS[@]}" -e robots=off -qO- https://check.torproject.org); then
			[[ $TOR_QUIET = true ]] || log::ok "[4/6] <check.torproject.org>"
		else
			log::fail "[4/6] Could not connect to <https://check.torproject.org>"
			exit 19
		fi
		# Grep for success message
		[[ $TOR_QUIET = true ]] || log::prog "[5/6] Tor external check"
		if echo "$CHECK_TORPROJECT" | grep "Congratulations. This browser is configured to use Tor." &>/dev/null; then
			[[ $TOR_QUIET = true ]] || log::ok "[5/6] Tor external check"
		else
			log::fail "[5/6] Tor external check failed!"
			log::fail "[5/6] <check.torproject.org> indicated Tor is not properly configured"
			exit 20
		fi
		# Grep for IP
		[[ $TOR_QUIET = true ]] || log::prog "[6/6] Exit IP"
		local IP_TORPROJECT=$(echo "$CHECK_TORPROJECT" | grep "Your IP address appears to be:")
		IP_TORPROJECT=${IP_TORPROJECT//[!0-9.]}
		if [[ $IP_TORPROJECT =~ [0-9.]+ ]]; then
			[[ $TOR_QUIET = true ]] || log::ok "[6/6] Exit IP <${IP_TORPROJECT}>"
		else
			log::warn "[6/6] <${IP_TORPROJECT}> Exit IP could not be found, continuing anyway"
		fi
	fi

	[[ $TORSOCKS_INIT = ___SET___ ]] || declare -gr TORSOCKS_INIT=___SET___
}

torsocks_func() {
	# Export [monero-bash.conf] variables
	# Tor IP
	export TORSOCKS_TOR_ADDRESS="$TOR_IP" || { print_Error "Torsocks error 20"; exit 20; }
	# Tor Port
	export TORSOCKS_TOR_PORT="$TOR_PORT" || { print_Error "Torsocks error 21"; exit 21; }
	# Silence messages
	export TORSOCKS_LOG_LEVEL=1 || { print_Error "Torsocks error 22"; exit 22; }

	# Torify
	torify_app "$@"
}
