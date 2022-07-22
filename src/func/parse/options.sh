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
log::debug "parsing user input"
log::debug "user input: $*"
until [[ $# = 0 ]]; do
case "$1" in
	uninstall) monero_bash::uninstall; exit;;
	rpc)       rpc::daemon "$@"; exit;;
	install)
		shift
		until [[ $# = 0 ]]; do
		case "$1" in
			*bash*)       OPTION_INSTALL_BASH=true;;
			monero)       OPTION_INSTALL_MONERO=true;;
			*p2p*)        OPTION_INSTALL_P2POOL=true;;
			*xmr*)        OPTION_INSTALL_XMRIG=true;;
			--force|-f)   OPTION_FORCE=true;;
			--verbose|-v) OPTION_VERBOSE=true;;
			"") print::error "Pick one/multiple packages"; print::version; exit 1;;
			*)            break;;
		esac
		shift
		done
		install::pkg
		exit
		;;
	remove)
		shift
		until [[ $# = 0 ]]; do
		case "$1" in
			*bash*)       OPTION_REMOVE_BASH=true;;
			monero)       OPTION_REMOVE_MONERO=true;;
			*p2p*)        OPTION_REMOVE_P2POOL=true;;
			*xmr*)        OPTION_REMOVE_XMRIG=true;;
			"") print::error "Pick one/multiple packages"; print::version; exit 1;;
			*)            break;;
		esac
		shift
		done
		remove::pkg
		exit
		;;
	update) update::pkg; exit;;
	upgrade)
		shift
		until [[ $# = 0 ]]; do
		case "$1" in
			*bash*)       OPTION_UPGRADE_BASH=true;;
			monero)       OPTION_UPGRADE_MONERO=true;;
			*p2p*)        OPTION_UPGRADE_P2POOL=true;;
			*xmr*)        OPTION_UPGRADE_XMRIG=true;;
			--force|-f)   OPTION_FORCE=true;;
			--verbose|-v) OPTION_VERBOSE=true;;
			"") print::error "Pick one/multiple packages"; print::version; exit 1;;
			*)            break;;
		esac
		shift
		done
		upgrade::pkg
		exit
		;;
	version) print::version; exit;;
	config)  config::mining; exit;;
	start)
		shift
		until [[ $# = 0 ]]; do
		case "$1" in
			*bash*)       OPTION_PROCESS_BASH=true;;
			monero)       OPTION_PROCESS_MONERO=true;;
			*p2p*)        OPTION_PROCESS_P2POOL=true;;
			*xmr*)        OPTION_PROCESS_XMRIG=true;;
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
			*bash*)       OPTION_PROCESS_BASH=true;;
			monero)       OPTION_PROCESS_MONERO=true;;
			*p2p*)        OPTION_PROCESS_P2POOL=true;;
			*xmr*)        OPTION_PROCESS_XMRIG=true;;
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
			*bash*)       OPTION_PROCESS_BASH=true;;
			monero)       OPTION_PROCESS_MONERO=true;;
			*p2p*)        OPTION_PROCESS_P2POOL=true;;
			*xmr*)        OPTION_PROCESS_XMRIG=true;;
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
			*bash*)       OPTION_PROCESS_BASH=true;;
			monero)       OPTION_PROCESS_MONERO=true;;
			*p2p*)        OPTION_PROCESS_P2POOL=true;;
			*xmr*)        OPTION_PROCESS_XMRIG=true;;
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
			*bash*)       OPTION_PROCESS_BASH=true;;
			monero)       OPTION_PROCESS_MONERO=true;;
			*p2p*)        OPTION_PROCESS_P2POOL=true;;
			*xmr*)        OPTION_PROCESS_XMRIG=true;;
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
			*bash*)       OPTION_PROCESS_BASH=true;;
			monero)       OPTION_PROCESS_MONERO=true;;
			*p2p*)        OPTION_PROCESS_P2POOL=true;;
			*xmr*)        OPTION_PROCESS_XMRIG=true;;
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
			*bash*)       OPTION_PROCESS_BASH=true;;
			monero)       OPTION_PROCESS_MONERO=true;;
			*p2p*)        OPTION_PROCESS_P2POOL=true;;
			*xmr*)        OPTION_PROCESS_XMRIG=true;;
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
	status) status::print; exit;;
	list)   wallet::list;  exit;;
	new)    wallet::create;exit;;
	size)   print::size;   exit;;
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
	help)   print::help;   exit;;
	*)
		log::debug "user input failed: $1"
		print::error "invalid option!"
		printf "${OFF}%s${BRED}%s${OFF}\n" \
			"for help, type:" \
			"monero-bash help"
		exit 1
		;;
esac
done
}
