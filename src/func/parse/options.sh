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

# parse user input

parse::options() {
log::debug "starting ${FUNCNAME}"
log::debug "user input: $*"
log::debug "unsetting OPTION variables"
unset -v OPTION_BASH OPTION_MONERO OPTION_P2POOL OPTION_XMRIG OPTION_VERBOSE OPTION_FORCE

until [[ $# = 0 ]]; do
case "$1" in
	new)       wallet::create  ;exit;;
	rpc)       rpc::daemon "$@";exit;;
	list)      wallet::list    ;exit;;
	size)      print::size     ;exit;;
	config)    config          ;exit;;
	status)    status          ;exit;;
	version)   print::version  ;exit;;
	uninstall) monero_bash::uninstall; exit;;
	help)
		shift
		___BEGIN___ERROR___TRACE___
		if [[ $1 ]]; then
			print::help::command "$@"
		else
			print::help
		fi
		exit
		___ENDOF___ERROR___TRACE___
		;;
	update)
		shift
		case "$1" in
			--verbose|-v) OPTION_VERBOSE=true;;
		esac
		___BEGIN___ERROR___TRACE___
		update
		exit
		___ENDOF___ERROR___TRACE___
		;;
	# PACKAGE MANAGER
	install)
		shift
		if [[ $# = 0 ]]; then
			print::error "Pick one/multiple packages"
			print::version
			exit 1
		fi
		until [[ $# = 0 ]]; do
		case "$1" in
			*bash*|*Bash*|*BASH*) OPTION_BASH=true;;
			monero|Monero|MONERO) OPTION_MONERO=true;;
			*p2p*|*P2p*|*P2P*)    OPTION_P2POOL=true;;
			*xmr*|*Xmr*|*XMR*)    OPTION_XMRIG=true;;
			--verbose|-v)         OPTION_VERBOSE=true;;
			*)
				print::error "Invalid option: $1"
				print::error "Pick one/multiple packages"
				print::version
				exit 1
				;;
		esac
		shift
		done
		___BEGIN___ERROR___TRACE___
		pkg::prompt install
		exit
		___ENDOF___ERROR___TRACE___
		;;
	remove)
		shift
		if [[ $# = 0 ]]; then
			print::error "Pick one/multiple packages"
			print::version
			exit 1
		fi
		until [[ $# = 0 ]]; do
		case "$1" in
			*bash*|*Bash*|*BASH*) OPTION_BASH=true;;
			monero|Monero|MONERO) OPTION_MONERO=true;;
			*p2p*|*P2p*|*P2P*)    OPTION_P2POOL=true;;
			*xmr*|*Xmr*|*XMR*)    OPTION_XMRIG=true;;
			*)
				print::error "Invalid option: $1"
				print::error "Pick one/multiple packages"
				print::version
				exit 1
				;;
		esac
		shift
		done
		___BEGIN___ERROR___TRACE___
		remove::prompt
		exit
		___ENDOF___ERROR___TRACE___
		;;
	upgrade)
		shift
		if [[ $# = 0 ]]; then
			print::error "Pick one/multiple packages"
			print::version
			exit 1
		fi
		until [[ $# = 0 ]]; do
		case "$1" in
			*bash*|*Bash*|*BASH*) OPTION_BASH=true;;
			monero|Monero|MONERO) OPTION_MONERO=true;;
			*p2p*|*P2p*|*P2P*)    OPTION_P2POOL=true;;
			*xmr*|*Xmr*|*XMR*)    OPTION_XMRIG=true;;
			--force|-f)           OPTION_FORCE=true;;
			--verbose|-v)         OPTION_VERBOSE=true;;
			*)
				print::error "Invalid option: $1"
				print::error "Pick one/multiple packages"
				print::version
				exit 1
				;;
		esac
		shift
		done
		___BEGIN___ERROR___TRACE___
		pkg::prompt
		exit
		___ENDOF___ERROR___TRACE___
		;;

	# PROCESS
	start)
		shift
		until [[ $# = 0 ]]; do
		case "$1" in
			*bash*)       OPTION_BASH=true;;
			monero)       OPTION_MONERO=true;;
			*p2p*)        OPTION_P2POOL=true;;
			*xmr*)        OPTION_XMRIG=true;;
			"") print::error "Pick one/multiple processes: [monerod/p2pool/xmrig]"; exit 1;;
			*)            break;;
		esac
		shift
		done
		process::start
		exit
		;;
	stop)
		shift
		until [[ $# = 0 ]]; do
		case "$1" in
			*bash*)       OPTION_BASH=true;;
			monero)       OPTION_MONERO=true;;
			*p2p*)        OPTION_P2POOL=true;;
			*xmr*)        OPTION_XMRIG=true;;
			"") print::error "Pick one/multiple processes: [monerod/p2pool/xmrig]"; exit 1;;
			*)            break;;
		esac
		shift
		done
		process::stop
		exit
		;;
	kill)
		shift
		until [[ $# = 0 ]]; do
		case "$1" in
			*bash*)       OPTION_BASH=true;;
			monero)       OPTION_MONERO=true;;
			*p2p*)        OPTION_P2POOL=true;;
			*xmr*)        OPTION_XMRIG=true;;
			"") print::error "Pick one/multiple processes: [monerod/p2pool/xmrig]"; exit 1;;
			*)            break;;
		esac
		shift
		done
		process::kill
		exit
		;;
	restart)
		shift
		until [[ $# = 0 ]]; do
		case "$1" in
			*bash*)       OPTION_BASH=true;;
			monero)       OPTION_MONERO=true;;
			*p2p*)        OPTION_P2POOL=true;;
			*xmr*)        OPTION_XMRIG=true;;
			"") print::error "Pick one/multiple processes: [monerod/p2pool/xmrig]"; exit 1;;
			*)            break;;
		esac
		shift
		done
		process::restart
		exit
		;;
	full)
		shift
		[[ $# -gt 1 ]] && print::error "Pick one process: [monerod/p2pool/xmrig]"; exit 1
		case "$1" in
			*bash*)       OPTION_BASH=true;;
			monero)       OPTION_MONERO=true;;
			*p2p*)        OPTION_P2POOL=true;;
			*xmr*)        OPTION_XMRIG=true;;
			"") print::error "Pick one process: [monerod/p2pool/xmrig]"; exit 1;;
			*)            break;;
		esac
		process::full
		exit
		;;
	watch)
		shift
		until [[ $# = 0 ]]; do
		case "$1" in
			*bash*)       OPTION_BASH=true;;
			monero)       OPTION_MONERO=true;;
			*p2p*)        OPTION_P2POOL=true;;
			*xmr*)        OPTION_XMRIG=true;;
			"") print::error "Pick one/multiple processes: [monerod/p2pool/xmrig]"; exit 1;;
			*)            break;;
		esac
		shift
		done
		process::watch
		exit
		;;
	edit)
		shift
		until [[ $# = 0 ]]; do
		case "$1" in
			*bash*)       OPTION_BASH=true;;
			monero)       OPTION_MONERO=true;;
			*p2p*)        OPTION_P2POOL=true;;
			*xmr*)        OPTION_XMRIG=true;;
			"") print::error "Pick one/multiple to edit: [monerod/p2pool/xmrig]"; exit 1;;
			*)            break;;
		esac
		shift
		done
		process::edit
		exit
		;;
	reset)
		shift
		case "$1" in
			*bash*) struct::pkg bash;;
			monero) struct::pkg monero;;
			*p2p*)  struct::pkg p2pool;;
			*xmr*)  struct::pkg xmrig;;
			*) print::error "Pick one/multiple to reset: [monerod/p2pool/xmrig]"; exit 1;;
		esac
		process::reset_files
		exit
		;;

	# MISC
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
		exit
		;;
	*)
		log::debug "user input failed: $1"
		print::error "Invalid option!"
		print::exit "$(printf "${OFF}%s${BYELLOW}%s${OFF}\n" "For help, type: " "monero-bash help")"
		;;
esac
done
}
