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

# parse case for packages
parse::options::pkg() {
	[[ $# = 1 ]] && print::help::command "$1"
	shift
	case "$1" in
		*bash*|*Bash*|*BASH*) OPTION_BASH=true;;
		monero|Monero|MONERO) OPTION_MONERO=true;;
		*p2p*|*P2p*|*P2P*)    OPTION_P2POOL=true;;
		*xmr*|*Xmr*|*XMR*)    OPTION_XMRIG=true;;
		*)
			print::error "Invalid option: $1"
			print::exit  "Pick one/multiple packages: [bash|monero|p2pool|xmrig]"
			;;
	esac
	until [[ $# = 0 ]]; do
	shift
	case "$1" in
		*bash*|*Bash*|*BASH*) OPTION_BASH=true;;
		monero|Monero|MONERO) OPTION_MONERO=true;;
		*p2p*|*P2p*|*P2P*)    OPTION_P2POOL=true;;
		*xmr*|*Xmr*|*XMR*)    OPTION_XMRIG=true;;
		--verbose|-v)         OPTION_VERBOSE=true;;
		--force|-f)           OPTION_FORCE=true;;
		"")                   return 0;;
		*)
			print::error "Invalid option: $1"
			print::exit  "Pick one/multiple packages: [bash|monero|p2pool|xmrig]"
			;;
	esac
	done
}

# parse case for processes including [monero-bash]
parse::options::process() {
	[[ $# = 1 ]] && print::help::command "$1"
	shift
	case "$1" in
		*bash*|*Bash*|*BASH*) OPTION_BASH=true;;
		monero|Monero|MONERO) OPTION_MONERO=true;;
		*p2p*|*P2p*|*P2P*)    OPTION_P2POOL=true;;
		*xmr*|*Xmr*|*XMR*)    OPTION_XMRIG=true;;
		*)
			print::error "Invalid option: $1"
			print::exit  "Pick one/multiple processes: [bash|monero|p2pool|xmrig]"
			;;
	esac
	until [[ $# = 0 ]]; do
	shift
	case "$1" in
		*bash*|*Bash*|*BASH*) OPTION_BASH=true;;
		monero|Monero|MONERO) OPTION_MONERO=true;;
		*p2p*|*P2p*|*P2P*)    OPTION_P2POOL=true;;
		*xmr*|*Xmr*|*XMR*)    OPTION_XMRIG=true;;
		"")                   return 0;;
		*)
			print::error "Invalid option: $1"
			print::exit  "Pick one/multiple processes: [bash|monero|p2pool|xmrig]"
			;;
	esac
	done
}

# parse case for systemd
parse::options::systemd() {
	[[ $# = 1 ]] && print::help::command "$1"
	until [[ $# = 0 ]]; do
	shift
	case "$1" in
		monero|Monero|MONERO) OPTION_MONERO=true;;
		*p2p*|*P2p*|*P2P*)    OPTION_P2POOL=true;;
		*xmr*|*Xmr*|*XMR*)    OPTION_XMRIG=true;;
		"")                   return 0;;
		*)
			print::error "Invalid option: $1"
			print::exit  "Pick one/multiple processes: [monero|p2pool|xmrig]"
			;;
	esac
	done
}

# parse user input
parse::options() {
log::debug "starting ${FUNCNAME}"
log::debug "user input: $*"
log::debug "unsetting OPTION variables"
unset -v OPTION_BASH OPTION_MONERO OPTION_P2POOL OPTION_XMRIG OPTION_VERBOSE OPTION_FORCE

case "$1" in

	# WALLET
	new)  wallet::create;;
	list) wallet::list;;
	size) print::size;;

	# PACKAGE MANAGER
	update)
		[[ $# = 1 ]] && print::help::command "$1"
		shift
		case "$1" in
			--verbose|-v) OPTION_VERBOSE=true;;
		esac
		___BEGIN___ERROR___TRACE___
		update
		___ENDOF___ERROR___TRACE___
		;;
	install)
		parse::options::pkg "$@"
		___BEGIN___ERROR___TRACE___
		pkg::prompt install
		___ENDOF___ERROR___TRACE___
		;;
	remove)
		parse::options::pkg "$@"
		___BEGIN___ERROR___TRACE___
		remove::prompt
		___ENDOF___ERROR___TRACE___
		;;
	upgrade)
		parse::options::pkg "$@"
		___BEGIN___ERROR___TRACE___
		pkg::prompt
		___ENDOF___ERROR___TRACE___
		;;

	# PROCESS
	full)
		[[ $# = 1 ]] && print::help::command "$1"
		shift
		[[ $# -gt 1 ]] && print::exit "Pick one process: [monero|p2pool|xmrig]"
		case "$1" in
			*bash*|*Bash*|*BASH*) OPTION_BASH=true;;
			monero|Monero|MONERO) OPTION_MONERO=true;;
			*p2p*|*P2p*|*P2P*)    OPTION_P2POOL=true;;
			*xmr*|*Xmr*|*XMR*)    OPTION_XMRIG=true;;
			*)
				print::error "Invalid process: $1"
				print::exit  "Pick one process: [monero|p2pool|xmrig]"
				;;
		esac
		process::full
		;;
	config)
		parse::options::process "$@"
		process::config
		;;
	default)
		[[ $# = 1 ]] && print::help::command "$1"
		shift
		case "$1" in
			*bash*|*Bash*|*BASH*) OPTION_BASH=true;;
			monero|Monero|MONERO) OPTION_MONERO=true;;
			*p2p*|*P2p*|*P2P*)    OPTION_P2POOL=true;;
			*xmr*|*Xmr*|*XMR*)    OPTION_XMRIG=true;;
			*)
				print::error "Invalid option: $1"
				print::error  "Pick one/multiple processes: [bash|monero|p2pool|xmrig]"
				;;
		esac
		until [[ $# = 0 ]]; do
		shift
		case "$1" in
			*bash*|*Bash*|*BASH*) OPTION_BASH=true;;
			monero|Monero|MONERO) OPTION_MONERO=true;;
			*p2p*|*P2p*|*P2P*)    OPTION_P2POOL=true;;
			*xmr*|*Xmr*|*XMR*)    OPTION_XMRIG=true;;
			--config|-c)          OPTION_CONFIG=true;;
			--systemd|-s)         OPTION_SYSTEMD=true;;
			*)
				print::error "Invalid process: $1"
				print::exit  "Pick one process: [bash|monero|p2pool|xmrig]"
				;;
		esac
		done
		process::default
		;;

	# SYSTEMD
	start)
		parse::options::systemd "$@"
		systemd::start
		;;
	stop)
		parse::options::systemd "$@"
		systemd::stop
		;;
	kill)
		parse::options::systemd "$@"
		systemd::kill
		;;
	restart)
		parse::options::systemd "$@"
		systemd::restart
		;;
	watch)
		parse::options::systemd "$@"
		systemd::watch
		;;
	edit)
		parse::options::systemd "$@"
		systemd::edit
		;;
	refresh)
		parse::options::systemd "$@"
		systemd::refresh
		;;
	enable)
		parse::options::systemd "$@"
		systemd::enable
		;;
	disable)
		parse::options::systemd "$@"
		systemd::disable
		;;

	# STATS
	status)  status;;
	version) print::version;;

	# OTHER
	uninstall) monero_bash::uninstall;;
	rpc)
		[[ $# = 1 ]] && print::help::command "$1"
		shift
		rpc "$@"
		;;
	changes)
		shift
		[[ $# = 0 ]] && print::changelog && exit
		until [[ $# = 0 ]]; do
			if declare -fp print::changelog::"${1/v}" &>/dev/null; then
				print::changelog::"${1/v}"
			else
				print::error "Version $1 does not exist/is not available"
			fi
			shift
		done
		;;
	help)
		shift
		___BEGIN___ERROR___TRACE___
		if [[ $1 ]]; then
			print::help::command "$@"
		else
			print::help
		fi
		___ENDOF___ERROR___TRACE___
		;;
	*)
		log::debug "user input failed: $*"
		print::error "Invalid option: $*"
		print::exit "$(printf "${OFF}%s${BYELLOW}%s${OFF}\n" "For help, type: " "monero-bash help")"
		;;
esac
exit
}
