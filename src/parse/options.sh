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
log::debug "unsetting OPTION variables"
unset -v OPTION_BASH OPTION_MONERO OPTION_P2POOL OPTION_XMRIG OPTION_VERBOSE OPTION_FORCE
log::debug "user input: $*"

case "$1" in

	# WALLET
	list) print::title; wallet::list;;
	size) print::size;;
	new)  shift; print::title; wallet::create "$@";;

	# PACKAGE MANAGER
	update)
		shift
		until [[ $# = 0 ]]; do
			case "$1" in
				--verbose|-v) OPTION_VERBOSE=true;;
				"")           :;;
				*)            print::help::command update;;
			esac
			shift
		done
		___BEGIN___ERROR___TRACE___
		pkg::update
		___ENDOF___ERROR___TRACE___
		;;
	install)
		[[ $# = 1 ]] && print::help::command "$1"
		shift
		until [[ $# = 0 ]]; do
			case "$1" in
				*bash*|*Bash*|*BASH*) OPTION_BASH=true;;
				monero|Monero|MONERO) OPTION_MONERO=true;;
				*p2p*|*P2p*|*P2P*)    OPTION_P2POOL=true;;
				*xmr*|*Xmr*|*XMR*)    OPTION_XMRIG=true;;
				--verbose|-v)         OPTION_VERBOSE=true;;
				--force|-f)           OPTION_FORCE=true;;
				*)
					print::error "Invalid option: $1"
					print::exit  "Pick one/multiple packages: [bash|monero|p2pool|xmrig]"
					;;
			esac
			shift
		done
		___BEGIN___ERROR___TRACE___
		pkg::prompt install
		___ENDOF___ERROR___TRACE___
		;;
	remove)
		[[ $# = 1 ]] && print::help::command "$1"
		shift
		until [[ $# = 0 ]]; do
			case "$1" in
				*bash*|*Bash*|*BASH*) OPTION_BASH=true;;
				monero|Monero|MONERO) OPTION_MONERO=true;;
				*p2p*|*P2p*|*P2P*)    OPTION_P2POOL=true;;
				*xmr*|*Xmr*|*XMR*)    OPTION_XMRIG=true;;
				--verbose|-v)         OPTION_VERBOSE=true;;
				*)
					print::error "Invalid option: $1"
					print::exit  "Pick one/multiple packages: [bash|monero|p2pool|xmrig]"
					;;
			esac
			shift
		done
		___BEGIN___ERROR___TRACE___
		pkg::remove::prompt
		___ENDOF___ERROR___TRACE___
		;;
	upgrade)
		shift
		until [[ $# = 0 ]]; do
			case "$1" in
				--verbose|-v)         OPTION_VERBOSE=true;;
				--force|-f)           OPTION_FORCE=true;;
				"")                   break;;
				*)
					print::exit "Invalid option: $1"
					;;
			esac
			shift
		done
		___BEGIN___ERROR___TRACE___
		pkg::prompt upgrade
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
		local i RPC_LIST
		for i in $@; do
			case "$i" in
				-v | --verbose) OPTION_VERBOSE=true;;
			esac
		done
		RPC_LIST=(${@//\-v})
		RPC_LIST=(${@//\-\-verbose})
		rpc "${RPC_LIST[@]}"
		;;
	changes)
		[[ $# = 1 ]] && print::help::command "$1"
		shift
		until [[ $# = 0 ]]; do
		case "$1" in
			*bash*|*Bash*|*BASH*) OPTION_BASH=true;;
			monero|Monero|MONERO) OPTION_MONERO=true;;
			*p2p*|*P2P*|*P2p*)    OPTION_P2POOL=true;;
			*xmr*|*Xmr*|*XMR*)    OPTION_XMRIG=true;;
			-p | --print)         OPTION_PRINT=true;;
			*)
				print::error "Invalid option: $1"
				print::exit  "Pick one package: [bash|monero|p2pool|xmrig]"
				;;
		esac
		shift
		done
		print::changes::list
		exit
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
