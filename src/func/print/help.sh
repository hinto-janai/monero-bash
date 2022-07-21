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

# print help screen (command list)
print::help() {
	printf "${BWHITE}%s${BRED}%s${OFF}%s${BYELLOW}%s${BPURPLE}%s\n\n" \
		"MONERO-BASH USAGE: " "monero-bash " "[command] " "<argument> " "[--option]"

	printf "${BWHITE}%s${OFF}\n" "WALLET"
	printf "    ${OFF}%s\n" \
		"monero-bash                              Open wallet menu" \
		"list                                     List wallets"

	printf "\n${BWHITE}%s${OFF}\n" "PACKAGE"
	printf "    ${OFF}%s${BYELLOW}%s${BPURPLE}%s${OFF}%s\n" \
		"install " "<packages> " "[--verbose]           " "Install one/multiple packages"
	printf "    ${OFF}%s${BYELLOW}%s${OFF}%s\n" \
		"remove  " "<packages>                          " "Remove one/multiple packages"
	printf "    ${OFF}%s\n" \
		"update                                   Check for package updates" \
		"upgrade                                  Upgrade all out-of-date packages"
	printf "    ${OFF}%s${BYELLOW}%s${BPURPLE}%s${OFF}%s\n" \
		"upgrade " "<packages> " "[--verbose|--force]   " "Upgrade SPECIFIC packages"

	printf "\n${BWHITE}%s${OFF}\n" "PROCESS"
	printf "    ${OFF}%s${BYELLOW}%s${OFF}%s\n" \
		"full    " "<monerod/p2pool/xmrig>           " "Start process fully attached in foreground" \
		"start   " "<monerod/p2pool/xmrig>           " "Start process as systemd background process" \
		"stop    " "<monerod/p2pool/xmrig>           " "Gracefully stop systemd background process" \
		"kill    " "<monerod/p2pool/xmrig>           " "Forcefully kill systemd background process" \
		"restart " "<monerod/p2pool/xmrig>           " "Restart systemd background process" \
		"watch   " "<monerod/p2pool/xmrig>           " "Watch live output of systemd background process" \
		"edit    " "<monero/p2pool/xmrig>            " "Edit systemd service file" \
		"reset   " "<bash/monero/p2pool/xmrig>       " "Reset your config/systemd service file to default"

	printf "\n${BWHITE}%s${OFF}\n"    "STATS"
	printf "    %s\n" \
		"status                                   Print status of all running processes" \
		"size                                     Print size of all packages and folders" \
		"version                                  Print current package versions"
	printf "    ${OFF}%s${BYELLOW}%s${OFF}%s\n" \
		"changes " "<monero-bash version>            " "Print current/specified monero-bash changelog"

	printf "\n${BWHITE}%s${OFF}\n"    "RPC"
	printf "    ${OFF}%s${BYELLOW}%s${OFF}%s\n" \
		"rpc     " "<JSON-RPC method>                " "Send a JSON-RPC call to monerod"

	printf "\n${BWHITE}%s${OFF}\n"    "HELP"
	printf "    %s\n" \
		"help                                     Print this help message"
}
