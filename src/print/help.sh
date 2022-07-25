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
	log::debug "starting"

	printf "${BWHITE}%s${BRED}%s${OFF}%s${BYELLOW}%s${BPURPLE}%s\n\n" \
		"USAGE: " "monero-bash " "[command] " "<argument> " "[--option]"

	printf "${BWHITE}%s${OFF}\n" "WALLET"
	printf "    ${OFF}%s\n" \
		"monero-bash                                Open interactive wallet menu" \
		"list                                       List wallets"
	printf "    ${OFF}%s${BYELLOW}%s${OFF}%s\n" \
		"new     " "<wallet type>                      " "Enter wallet creation mode"

	printf "\n${BWHITE}%s${OFF}\n" "PACKAGE"
	printf "    ${OFF}%s${BYELLOW}%s${BPURPLE}%s${OFF}%s\n" \
		"install " "<packages> " "[--verbose]             " "Install one/multiple packages" \
		"remove  " "<packages> " "[--verbose]             " "Remove one/multiple packages"
	printf "    ${OFF}%s${BPURPLE}%s${OFF}%s\n" \
		"update  " "[--verbose]                        " "Check for package updates" \
		"upgrade " "[--verbose] [--force]              " "Upgrade all out-of-date packages"

	printf "\n${BWHITE}%s${OFF}\n" "PROCESS"
	printf "    ${OFF}%s${BYELLOW}%s${OFF}%s\n" \
		"full    " "<process>                          " "Start <process> fully attached in foreground" \
		"config  " "<processes>                        " "Enter interactive configuration for <process>"
	printf "    ${OFF}%s${BYELLOW}%s${BPURPLE}%s${OFF}%s\n" \
		"default " "<processes> " "[--config] [--systemd] " "Reset your config/systemd file to the default"

	printf "\n${BWHITE}%s${OFF}\n" "SYSTEMD"
	printf "    ${OFF}%s${BYELLOW}%s${OFF}%s\n" \
		"start   " "<processes>                        " "Start process as systemd background process" \
		"stop    " "<processes>                        " "Gracefully stop systemd background process" \
		"kill    " "<processes>                        " "Forcefully kill systemd background process" \
		"restart " "<processes>                        " "Restart systemd background process" \
		"enable  " "<processes>                        " "Enable <process> to auto-start on computer boot" \
		"disable " "<processes>                        " "Disable <process> from auto-starting on computer boot" \
		"edit    " "<processes>                        " "Edit systemd service file" \
		"refresh " "<processes>                        " "Refresh your systemd service file to match your config" \
		"watch   " "<processes>                        " "Watch live output of systemd background process"

	printf "\n${BWHITE}%s${OFF}\n"    "STATS"
	printf "    %s\n" \
		"status                                     Print status of all running processes" \
		"size                                       Print size of all packages and folders" \
		"version                                    Print current package versions"
	printf "\n${BWHITE}%s${OFF}\n"    "OTHER"
	printf "    ${OFF}%s${BYELLOW}%s${OFF}%s\n" \
		"rpc     " "<JSON-RPC method>                  " "Send a JSON-RPC call to monerod" \
		"changes " "<package>                          " "Print the latests changes for <package>" \
		"help    " "<command>                          " "Print help for a command, or all if none specified"
}

# print specific help messages for commands
print::help::command() {
	until [[ $# = 0 ]]; do
	log::debug "starting ${FUNCNAME}() for: $1"
	case "$1" in

		#WALLET
		monero-bash)
			printf "${BWHITE}%s${BRED}%s\n\n" "USAGE: " "monero-bash"
			printf "${OFF}%s\n" \
			"Open the interactive wallet menu." \
			"" \
			"Looks for wallets inside the wallet folder:" \
			"[\$HOME/.monero-bash/wallets]" \
			"Ignores [.keys] files, only looking for wallet files." \
			"" \
			"Allows selection of existing wallets and interactive" \
			"creation of a new wallet with these types: " \
			"" \
			"--generate-new-wallet         | [new]" \
			"--generate-from-view-key      | [view]" \
			"--restore-from-seed           | [seed]" \
			"--generate-from-json          | [json]" \
			"--generate-from-spend-key     | [spend]" \
			"--generate-from-device        | [device]" \
			"--generate-from-keys          | [private]" \
			"--generate-from-multisig-keys | [multisig]" \
			"" \
			"Each time the [monero-bash] title is printed, it rolls" \
			"some RNG to print varying levels of title rarity:" \
			"" \
			"RED    # | common    | 60%" \
			"BLUE   x | rare      | 30%" \
			"PURPLE : | ultra     | 9%" \
			"GOLDEN / | legendary | 0.99%" \
			"GREEN  # | lottery   | 0.0030519%"
			;;
		list)
			printf "${BWHITE}%s${BRED}%s${OFF}%s\n\n" "USAGE: " "monero-bash " "list"
			printf "${OFF}%s\n" \
			"Print the full list and amount of wallets." \
			"" \
			"Looks for wallets inside of the wallet folder:" \
			"[\$HOME/.monero-bash/wallets]" \
			"Ignores [.keys] files, only looking for wallet files." \
			"" \
			"Each time the [monero-bash] title is printed, it rolls" \
			"some RNG to print varying levels of title rarity:" \
			"" \
			"RED    # | common    | 60%" \
			"BLUE   x | rare      | 30%" \
			"PURPLE : | ultra     | 9%" \
			"GOLDEN / | legendary | 0.99%" \
			"GREEN  # | lottery   | 0.0030519%"
			;;
		new)
			printf "${BWHITE}%s${BRED}%s${OFF}%s${BYELLOW}%s\n\n" "USAGE: " "monero-bash " "new " "<wallet type>"
			printf "${OFF}%s\n" \
			"Create a new wallet." \
			"" \
			"If a wallet type is given, wallet creation is started" \
			"with that type, if no wallet type is given, interactive" \
			"wallet creation mode is started. Creates wallets inside" \
			"of the wallet folder: [\$HOME/.monero-bash/wallets]" \
			"Allows creation of a wallet with these types:" \
			"" \
			"--generate-new-wallet         | [new]" \
			"--generate-from-view-key      | [view]" \
			"--restore-from-seed           | [seed]" \
			"--generate-from-json          | [json]" \
			"--generate-from-spend-key     | [spend]" \
			"--generate-from-device        | [device]" \
			"--generate-from-keys          | [private]" \
			"--generate-from-multisig-keys | [multisig]"
			;;

		# PACKAGE
		install)
			printf "${BWHITE}%s${BRED}%s${OFF}%s${BYELLOW}%s${BPURPLE}%s\n\n" "USAGE: " "monero-bash " "install " "<packages> " "[--verbose]"
			printf "${OFF}%s\n" \
			"Start the installation process of packages." \
			"" \
			"Packages are installed in their respective folders in:" \
			"[\$HOME/.monero-bash/packages/<PACKAGE_NAME>]" \
			"and [systemd] service files are created, if not already" \
			"found in: [/etc/systemd/system]" \
			"" \
			"Packages are verified by hash and PGP signature before" \
			"installation. PGP keys are automatically verified, then" \
			"imported if not already found. If verification fails, the" \
			"package will not be installed. The rest of the packages" \
			"will continue to be installed." \
			"" \
			"A single package or multiple packages can be installed at the same time." \
			"" \
			"--- PACKAGE LIST ---" \
			"[monero]" \
			"[p2pool]" \
			"[xmrig]" \
			"" \
			"If the [--verbose] option is given, detailed" \
			"debug information will be printed during the install."
			;;
		remove)
			printf "${BWHITE}%s${BRED}%s${OFF}%s${BYELLOW}%s${BPURPLE}%s\n\n" "USAGE: " "monero-bash " "remove " "<packages> " "[--verbose]"
			printf "${OFF}%s\n" \
			"Start the removal process of packages." \
			"" \
			"Packages folders are deleted: [\$HOME/.monero-bash/packages/<PACKAGE_NAME>]" \
			"and systemd service files are removed: [/etc/systemd/system/<PACKAGE_NAME>.service]" \
			"Configuration files are left alone: [\$HOME/.monero-bash/config/<PACKAGE_CONFIG>]" \
			"A single package or multiple packages can be removed at the same time." \
			"" \
			"--- PACKAGE LIST ---" \
			"[monero]" \
			"[p2pool]" \
			"[xmrig]" \
			"" \
			"If the [--verbose] option is given, detailed" \
			"debug information will be printed during the removal."
			;;
		update)
			printf "${BWHITE}%s${BRED}%s${OFF}%s${BPURPLE}%s\n\n" "USAGE: " "monero-bash " "update " "[--verbose]"
			printf "${OFF}%s\n" \
			"Check for new versions of installed packages." \
			"" \
			"If a new version is found, the new update will" \
			"be printed along with the old version:" \
			"<PACKAGE_NAME> | [OLD_VERSION] -> [NEW_VERSION]" \
			"The package version from that point will be" \
			"printed in [RED] instead of [GREEN] until it" \
			"is upgraded with [monero-bash upgrade]." \
			"" \
			"If the [--verbose] option is given, detailed" \
			"debug information will be printed during the update."
			;;
		upgrade)
			printf "${BWHITE}%s${BRED}%s${OFF}%s${BPURPLE}%s\n\n" "USAGE: " "monero-bash " "upgrade " "[--verbose]"
			printf "${OFF}%s\n" \
			"Upgrade all installed packages that are out-of-date." \
			"" \
			"Packages folders are upgraded:" \
			"[\$HOME/.monero-bash/packages/<PACKAGE_NAME>]" \
			"" \
			"Packages are verified by hash and PGP signature before" \
			"upgrade. PGP keys are automatically verified, then" \
			"imported if not already found. If verification fails, the" \
			"package will not be upgraded. The rest of the packages" \
			"will continue to be upgraded." \
			"" \
			"--- PACKAGE LIST ---" \
			"[monero]" \
			"[p2pool]" \
			"[xmrig]" \
			"" \
			"If the [--verbose] option is given, detailed" \
			"debug information will be printed during the upgrade."
			;;

		# PROCESS
		full)
			printf "${BWHITE}%s${BRED}%s${OFF}%s${BYELLOW}%s\n\n" "USAGE: " "monero-bash " "full " "<process>"
			printf "${OFF}%s\n" \
			"Start a process attached to the current terminal." \
			"" \
			"The process will be started in the foreground in the" \
			"current terminal with configuration sourced from the" \
			"process's configuration file found in:" \
			"[\$HOME/.monero-bash/config/<PROCESS_CONFIG>]" \
			"" \
			"The process will be ran as the [monero-bash] user for" \
			"security reasons. It has a [nologin] shell. The exeception" \
			"is [XMRig] which runs as [root] for hugepage allocation." \
			"This can be disabled by editing the XMRIG_ROOT option in:" \
			"[\$HOME/.monero-bash/config/monero-bash.conf]"\
			"" \
			"#---------------------------------------------------------------#" \
			"# PROCESS | USER        | CONFIG FILE                           #" \
			"#---------------------------------------------------------------#" \
			"# Monero  | monero-bash | monerod.conf & monero-wallet-cli.conf #" \
			"# P2Pool  | monero-bash | p2pool.conf (& optional p2pool.json)  #" \
			"# XMRig   | root        | xmrig.json                            #" \
			"#---------------------------------------------------------------#"
			;;
		config)
			printf "${BWHITE}%s${BRED}%s${OFF}%s${BYELLOW}%s\n\n" "USAGE: " "monero-bash " "config " "<processes>"
			printf "${OFF}%s\n" \
			"Start interactive configuration for processes." \
			"" \
			"This will edit the configuration files found in:" \
			"[\$HOME/.monero-bash/config/<PROCESS_CONFIG>]" \
			"" \
			"#-----------------------------------------------------#" \
			"# PROCESS     | CONFIG FILE                           #" \
			"#-----------------------------------------------------#" \
			"# monero-bash | monero-bash.conf                      #" \
			"# Monero      | monerod.conf & monero-wallet-cli.conf #" \
			"# P2Pool      | p2pool.conf                           #" \
			"# XMRig       | xmrig.json                            #" \
			"#-----------------------------------------------------#" \
			"" \
			"After configuration, a prompt will ask you if you'd like to" \
			"refresh your [systemd] service to match the configuration." \
			"This can also manually be done with: [monero-bash refresh <processes>]"
			;;
		default)
			printf "${BWHITE}%s${BRED}%s${OFF}%s${BYELLOW}%s${BPURPLE}%s\n\n" "USAGE: " "monero-bash " "default " "<processes> " "[--config] [--systemd]"
			printf "${OFF}%s\n" \
			"Reset config files/systemd services to the default." \
			"" \
			"This will reset the configuration files of <process>" \
			"found in: [\$HOME/.monero-bash/config/<PROCESS_CONFIG>]" \
			"and the [systemd] service files found in: [/etc/systemd/system]" \
			"to a generic default version." \
			"" \
			"#-----------------------------------------------------------------------------------#" \
			"# PROCESS     | CONFIG FILE                           | SYSTEMD SERVICE FILE        #" \
			"#-----------------------------------------------------------------------------------#" \
			"# monero-bash | monero-bash.conf                      |                             #" \
			"# Monero      | monerod.conf & monero-wallet-cli.conf | monero-bash-monerod.service #" \
			"# P2Pool      | p2pool.conf                           | monero-bash-p2pool.service  #" \
			"# XMRig       | xmrig.json                            | monero-bash-xmrig.service   #" \
			"#-----------------------------------------------------------------------------------#" \
			"" \
			"If no options are supplied, both the config file and systemd file are reset."
			;;

		# SYSTEMD
		start)
			printf "${BWHITE}%s${BRED}%s${OFF}%s${BYELLOW}%s\n\n" "USAGE: " "monero-bash " "start " "<processes>"
			printf "${OFF}%s\n" \
			"Start a process in the background with systemd" \
			"" \
			"The process will be started in the background with a" \
			"[systemd] service file found in: [/etc/systemd/system]" \
			"" \
			"The process will be ran as the [monero-bash] user for" \
			"security reasons. It has a [nologin] shell. The exeception" \
			"is [XMRig] which runs as [root] for hugepage allocation." \
			"This can be disabled by editing the XMRIG_ROOT option in:" \
			"[\$HOME/.monero-bash/config/monero-bash.conf]"\
			"and then refreshing the [systemd] service with:" \
			"[monero-bash refresh xmrig]" \
			"" \
			"#-----------------------------------------------------#" \
			"# PROCESS | USER        | SYSTEMD SERVICE FILE        #" \
			"#-----------------------------------------------------#" \
			"# Monero  | monero-bash | monero-bash-monerod.service #" \
			"# P2Pool  | monero-bash | monero-bash-p2pool.service  #" \
			"# XMRig   | root        | monero-bash-xmrig.service   #" \
			"#-----------------------------------------------------#"
			;;
		stop)
			printf "${BWHITE}%s${BRED}%s${OFF}%s${BYELLOW}%s\n\n" "USAGE: " "monero-bash " "stop " "<processes>"
			printf "${OFF}%s\n" \
			"Gracefully stop a background process with systemd" \
			"" \
			"[systemd] service files are found in: [/etc/systemd/system]" \
			"" \
			"#---------------------------------------#" \
			"# PROCESS | SYSTEMD SERVICE FILE        #" \
			"#---------------------------------------#" \
			"# Monero  | monero-bash-monerod.service #" \
			"# P2Pool  | monero-bash-p2pool.service  #" \
			"# XMRig   | monero-bash-xmrig.service   #" \
			"#---------------------------------------#"
			;;
		kill)
			printf "${BWHITE}%s${BRED}%s${OFF}%s${BYELLOW}%s\n\n" "USAGE: " "monero-bash " "kill " "<processes>"
			printf "${OFF}%s\n" \
			"Forcefully kill a background process with systemd" \
			"" \
			"[systemd] service files are found in: [/etc/systemd/system]" \
			"" \
			"#---------------------------------------#" \
			"# PROCESS | SYSTEMD SERVICE FILE        #" \
			"#---------------------------------------#" \
			"# Monero  | monero-bash-monerod.service #" \
			"# P2Pool  | monero-bash-p2pool.service  #" \
			"# XMRig   | monero-bash-xmrig.service   #" \
			"#---------------------------------------#"
			;;
		restart)
			printf "${BWHITE}%s${BRED}%s${OFF}%s${BYELLOW}%s\n\n" "USAGE: " "monero-bash " "restart " "<processes>"
			printf "${OFF}%s\n" \
			"Gracefully restart a background process with systemd" \
			"" \
			"[systemd] service files are found in: [/etc/systemd/system]" \
			"" \
			"#---------------------------------------#" \
			"# PROCESS | SYSTEMD SERVICE FILE        #" \
			"#---------------------------------------#" \
			"# Monero  | monero-bash-monerod.service #" \
			"# P2Pool  | monero-bash-p2pool.service  #" \
			"# XMRig   | monero-bash-xmrig.service   #" \
			"#---------------------------------------#"
			;;
		enable)
			printf "${BWHITE}%s${BRED}%s${OFF}%s${BYELLOW}%s\n\n" "USAGE: " "monero-bash " "enable " "<processes>"
			printf "${OFF}%s\n" \
			"Enable a background process to auto-start" \
			"on computer boot with systemd" \
			"" \
			"[systemd] service files are found in: [/etc/systemd/system]" \
			"" \
			"#---------------------------------------#" \
			"# PROCESS | SYSTEMD SERVICE FILE        #" \
			"#---------------------------------------#" \
			"# Monero  | monero-bash-monerod.service #" \
			"# P2Pool  | monero-bash-p2pool.service  #" \
			"# XMRig   | monero-bash-xmrig.service   #" \
			"#---------------------------------------#"
			;;
		disable)
			printf "${BWHITE}%s${BRED}%s${OFF}%s${BYELLOW}%s\n\n" "USAGE: " "monero-bash " "disable " "<processes>"
			printf "${OFF}%s\n" \
			"Disable background process from auto-start" \
			"on computer boot with systemd" \
			"" \
			"[systemd] service files are found in: [/etc/systemd/system]" \
			"" \
			"#---------------------------------------#" \
			"# PROCESS | SYSTEMD SERVICE FILE        #" \
			"#---------------------------------------#" \
			"# Monero  | monero-bash-monerod.service #" \
			"# P2Pool  | monero-bash-p2pool.service  #" \
			"# XMRig   | monero-bash-xmrig.service   #" \
			"#---------------------------------------#"
			;;
		edit)
			printf "${BWHITE}%s${BRED}%s${OFF}%s${BYELLOW}%s\n\n" "USAGE: " "monero-bash " "edit " "<processes>"
			printf "${OFF}%s\n" \
			"Edit a process's systemd service file." \
			"" \
			"After editing, systemd is reloaded automatically." \
			"[systemd] service files are found in: [/etc/systemd/system]" \
			"" \
			"#---------------------------------------#" \
			"# PROCESS | SYSTEMD SERVICE FILE        #" \
			"#---------------------------------------#" \
			"# Monero  | monero-bash-monerod.service #" \
			"# P2Pool  | monero-bash-p2pool.service  #" \
			"# XMRig   | monero-bash-xmrig.service   #" \
			"#---------------------------------------#"
			;;
		refresh)
			printf "${BWHITE}%s${BRED}%s${OFF}%s${BYELLOW}%s\n\n" "USAGE: " "monero-bash " "refresh " "<processes> "
			printf "${OFF}%s\n" \
			"Refresh [systemd] to match configuration files." \
			"" \
			"This will reset the [systemd] service of <process>" \
			"to match the configuration options found in:" \
			"[\$HOME/.monero-bash/config/<PROCESS_CONFIG>]" \
			"" \
			"By default, packages will come with a generic [systemd] service file." \
			"" \
			"#---------------------------------------------------------------------------#" \
			"# PROCESS     | CONFIG FILE TO MATCH          | SYSTEMD SERVICE FILE        #" \
			"#---------------------------------------------------------------------------#" \
			"# Monero      | monerod.conf                  | monero-bash-monerod.service #" \
			"# P2Pool      | p2pool.conf                   | monero-bash-p2pool.service  #" \
			"# XMRig       | monero-bash.conf + xmrig.json | monero-bash-xmrig.service   #" \
			"#---------------------------------------------------------------------------#" \
			"" \
			"If no options are supplied, both the config file and systemd file are reset."
			;;
		watch)
			printf "${BWHITE}%s${BRED}%s${OFF}%s${BYELLOW}%s\n\n" "USAGE: " "monero-bash " "watch " "<processes>"
			printf "${OFF}%s\n" \
			"Watch live output of a background systemd process" \
			"" \
			"The terminal will switch to output of <processes>" \
			"To exit and return: <CTRL+C>" \
			"If multiple procceses are selected, they are queued." \
			"" \
			"--- PROCESSES ---" \
			"[monero]" \
			"[p2pool]" \
			"[xmrig]"
			;;

		# STATUS
		status)
			printf "${BWHITE}%s${BRED}%s${OFF}%s\n\n" "USAGE: " "monero-bash " "status"
			printf "${OFF}%s\n" \
			"Print status of all running processes." \
			"" \
			"#---------------------------------------------------------------------------#" \
			"# PROCESS     | INFORMATION PRINTED                                         #" \
			"#---------------------------------------------------------------------------#" \
			"# Monero      | Blockchain stats + /.bitmonero/ size                        #" \
			"# P2Pool      | Wallet + Latest share + Latest payout + Shares per hour/day #" \
			"# XMRig       | Wallet + Hashrate + Shares + Pool                           #" \
			"#---------------------------------------------------------------------------#"
			;;
		size)
			printf "${BWHITE}%s${BRED}%s${OFF}%s\n\n" "USAGE: " "monero-bash " "size"
			printf "${OFF}%s\n" "Print size of installed packages and blockchain folder."
			;;
		version)
			printf "${BWHITE}%s${BRED}%s${OFF}%s\n\n" "USAGE: " "monero-bash " "version"
			printf "${OFF}%s\n" \
			"Print version of installed packages." \
			"" \
			"Versions will be printed in [BOLD RED] if they" \
			"are out-of-date. Otherwise they will be printed" \
			"in [BOLD GREEN]."
			;;
		# OTHER
		rpc)
			printf "${BWHITE}%s${BRED}%s${OFF}%s${BBLUE}%s${BYELLOW}%s${BGREEN}%s\n\n" "USAGE: " "monero-bash " "rpc " "[host:port] " "<JSON-RPC method> " "[name:value]"
			printf "${OFF}%s\n" \
			"Send a JSON-RPC call to monerod." \
			"" \
			"This will send a JSON-RPC call to the monerod IP" \
			"specified in [\$HOME/.monero-bash/config/monero-bash.conf]" \
			"Setting RPC_VERBOSE to true will make [monero-bash] print" \
			"the payload before sending." \
			"" \
			"The default IP is your own monerod: [127.0.0.1:18081]" \
			"But any monerod IP is able to be used: [node.community.rino.io:18081]" \
			"" \
			"The code for this function is originally from: https://github.com/jtgrassie/xmrpc" \
			"Copyright (c) 2014-2022, The Monero Project"

			printf "\n${BWHITE}%s${OFF}\n" "EXAMPLE"
			printf "    ${BRED}%s${OFF}%s${BYELLOW}%s\n" "monero-bash " "rpc " "get_block"
			printf "    ${BRED}%s${OFF}%s${BBLUE}%s${BYELLOW}%s\n" "monero-bash " "rpc " "node.community.rino.io:18081 " "get_block"
			printf "    ${BRED}%s${OFF}%s${BBLUE}%s${BYELLOW}%s${BGREEN}%s\n" \
			"monero-bash " "rpc " "127.0.0.1:18081 " "get_block " "height:123456" \
			"monero-bash " "rpc " "localhost:18081 " "get_block " "hash:418015bb9ae982a1975da7d79277c2705727a56894ba0fb246adaabb1f4632e3"

			printf "\n${BWHITE}%s${OFF}\n" "JSON RPC Methods"
			printf "    ${OFF}%s\n" \
			"get_block_count" \
			"on_get_block_hash" \
			"get_block_template" \
			"submit_block" \
			"get_last_block_header" \
			"get_block_header_by_hash" \
			"get_block_header_by_height" \
			"get_block_headers_range" \
			"get_block" \
			"get_connections" \
			"get_info" \
			"hard_fork_info" \
			"set_bans" \
			"get_bans" \
			"get_output_histogram" \
			"get_version" \
			"get_coinbase_tx_sum" \
			"get_fee_estimate" \
			"get_alternate_chains" \
			"relay_tx" \
			"sync_info" \
			"get_txpool_backlog" \
			"get_output_distribution"
			;;
		changes)
			printf "${BWHITE}%s${BRED}%s${OFF}%s${BYELLOW}%s\n\n" "USAGE: " "monero-bash " "changes " "<package>"
			printf "${OFF}%s\n" \
			"Print the changelog of <package>." \
			"" \
			"During package installations/upgrades, [monero-bash]" \
			"will save a local changelog inside:" \
			"[\$HOME/.monero-bash/packages/changes]" \
			"This file is read and parsed for MARKDOWN syntax, then printed."
			;;
		help)
			printf "${BWHITE}%s${BRED}%s${OFF}%s${BYELLOW}%s\n\n" "USAGE: " "monero-bash " "help " "<command>"
			printf "${OFF}%s\n" \
			"Print help for [monero-bash] commands." \
			"" \
			"If no command is given, the general help" \
			"menu will be printed for all commands."
			;;
		*) print::error "Invalid option: $1 command does not exist";;
	esac
	shift
	done

	exit
}
