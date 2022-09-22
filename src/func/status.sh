# This file is part of [monero-bash]
#
# Copyright (c) 2022 hinto.janaiyo
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
#
# Parts of this project are originally:
# Copyright (c) 2019-2022, jtgrassie
# Copyright (c) 2014-2022, The Monero Project
# Copyright (c) 2011-2022, Dominic Tarr
#
# Parts of this project are licensed under GPLv2:
# Copyright (c) ????-2022, Tamas Szerb <toma@rulez.org>
# Copyright (c) 2008-2022, Robert Hogan <robert@roberthogan.net>
# Copyright (c) 2008-2022, David Goulet <dgoulet@ev0ke.net>
# Copyright (c) 2008-2022, Alex Xu (Hello71) <alex_y_xu@yahoo.ca>


# status function, prints multiple helpful stats

status_All()
{
	[[ $XMRIG_VER ]] && { prompt_Sudo;error_Sudo; }
	print_MoneroBashTitle
	print_Installed_Version
	status_System
	[[ $MONERO_VER ]] && status_Monero
	[[ $P2POOL_VER ]] && status_P2Pool
	[[ $XMRIG_VER ]]  && status_XMRig
	exit 0
}

# same as above, just don't print title
# for `monero-bash watch status`
# (it wastes line space)
status_Watch() {
	[[ $MONERO_VER ]] && status_Monero
	[[ $P2POOL_VER ]] && status_P2Pool
	[[ $XMRIG_VER ]]  && status_XMRig
	return 0
}

status_System()
{
	printf "${BBLUE}%s${IWHITE}%s${OFF}%s\n\n" "System      | " "$(uptime -p)"
}

status_Template()
{
	printf "${OFF}%s${BWHITE}%s" "[" "${NAME_PRETTY} "
	declare -g PROCESS_ID
	if PROCESS_ID=$(pgrep -f $DIRECTORY/$PROCESS);then
		printf "${BGREEN}%s${OFF}%s\n" "ONLINE" "]"

		# ps stats
		ps -o "| %C | %t | %p |" -p $PROCESS_ID
		echo "--------------------------------"
		# process specific stats
		EXTRA_STATS
		echo
	else
		printf "${BRED}%s${OFF}%s\n\n" "OFFLINE" "]"
	fi
}

status_Monero()
{
	define_Monero
	EXTRA_STATS()
	{
		# [monero-bash.conf DAEMON_RPC_IP call]
		if [[ $DAEMON_RPC_IP = *:* ]]; then
			:
		elif DAEMON_RPC_IP=$(grep -E "^rpc-bind-ip=(|'|\")[0-9].*$" $config/monerod.conf); then
			if DAEMON_RPC_PORT=$(grep -E "^rpc-bind-port=(|'|\")[0-9].*$" $config/monerod.conf); then
				print_Warn "[DAEMON_RPC_IP] not found in [monero-bash.conf]"
				print_Warn "Falling back to [monerod.conf]'s [${DAEMON_RPC_IP//*=}:${DAEMON_RPC_PORT//*=}]"
				DAEMON_RPC_IP=${DAEMON_RPC_IP//*=}:${DAEMON_RPC_PORT//*=}
			fi
		# [localhost:18081] fallback
		else
			DAEMON_RPC_IP=localhost:18081
			print_Warn "[DAEMON_RPC_IP] not found in [monero-bash.conf]"
			print_Warn "[rpc-bind-ip] and/or [rpc-bind-port] not found in [monerod.conf]"
			print_Warn "Falling back to [localhost:18081]"
		fi
		# Warn against Tor on non-local host
		case $DAEMON_RPC_IP in
			localhost*|127.0.0.1*|192.168*) :;;
			*)
				if [[ $USE_TOR = true ]]; then
					print_Error "Getting Monero stats via a non-local [DAEMON_RPC_IP] over Tor is not supported!"
					print_Error_Exit "Please run your own node to get stats!"
				fi
		;;
		esac
		GET_INFO=$(wget -qO- "$DAEMON_RPC_IP/json_rpc" --header='Content-Type:application/json' --post-data='{"jsonrpc":"2.0","id":"0","method":"get_info"}')
		if [[ $? != 0 || -z $GET_INFO || $GET_INFO = *error* ]]; then
			printf "\e[1;91m%s\e[0;97m%s\e[0m\n" "Warning | " "Could not connect to [$DAEMON_RPC_IP] to get Monero stats!"
			return 1
		fi

		# turn RPC JSON values into variables.
		# this uses: https://github.com/hinto-janaiyo/libjson
		local $(echo "$GET_INFO" | json::var)

		local height_percent percent_color
		local -n height=result_height target_height=result_target_height incoming=result_incoming_connections_count outgoing=result_outgoing_connections_count rpc=result_rpc_connections_count synchronized=result_synchronized nettype=result_nettype target_height=result_target_height tx_pool_size=result_tx_pool_size net_hash=result_difficulty database_size=result_database_size free_space=result_free_space
		if [[ $result_synchronized = *true* ]]; then
			local -n target_height=height
			height_percent="100"
			percent_color="\e[92m"
		else
			# prevent dividing by 0
			# $height gets found first
			# before $target_height
			[[ $target_height -lt 2694035 ]] && height_percent=???
		fi

		# do all awk calculations
		# in one invocation for speed
		# awkList[0] = height_percent
		# awkList[1] = net_hash
		# awkList[2] = database_size
		# awkList[3] = free_space
		if [[ $height_percent = '???' ]]; then
			percent_color="\e[93m"
			local -a awkList=($(echo "$net_hash" "$database_size" "$free_space" "$GET_CONNECTIONS" \
				| awk '{printf "%.3f\n%.3f\n%.3f", $1 / 120000000000, $2 / 1000000000, $3 / 1000000000}'))
			local -n net_hash=awkList[0] database_size=awkList[1] free_space=awkList[2]
		else
			local -a awkList=($(echo "$height" "$target_height" "$net_hash" "$database_size"	"$free_space" \
				| awk '{printf "%.2f\n%.3f\n%.3f\n%.3f", $1 / $2 * 100, $3 / 120000000000, $4 / 1000000000, $5 / 1000000000}'))
			local -n height_percent=awkList[0] net_hash=awkList[1] database_size=awkList[2] free_space=awkList[3]
		fi
		if [[ -z $percent_color ]]; then
			if [[ ${height_percent//.*} -le 30 ]]; then
				percent_color="\e[91m"
			else
				percent_color="\e[93m"
			fi
		fi

		# print
		printf "${BWHITE}%s" "Size       | "; printf "\e[0m%s\e[97m%s\e[0m%s\e[97m%s\e[0m%s\n" "[blockchain: " "${database_size}GB" "] [disk: " "${free_space}GB" "]"
		printf "${BWHITE}%s" "Height     | "; printf "\e[0m%s${percent_color}%s\e[0m%s\e[92m%s\e[0m%s${percent_color}%s\e[0m%s\e[96m%s\e[0m%s\n" \
			"[" "$height" "/" "$target_height" "] (" "${height_percent}%" ") on [" "$nettype" "]"
		printf "${BWHITE}%s" "Network    | "; printf "\e[0m%s\e[95m%s\e[0m%s\e[94m%s\e[0m%s${IWHITE}%s${OFF}%s${IWHITE}%s${OFF}%s\n" "[" "tx: $tx_pool_size" "] [" "hash: ${net_hash}GH/s" "] [synced: " "$result_synchronized" "]"
		printf "${BWHITE}%s" "Connection | "; printf "\e[0m%s\e[93m%s\e[0m%s\e[92m%s\e[0m%s\e[91m%s\e[0m%s${IWHITE}%s${OFF}%s${IWHITE}%s${OFF}%s\n" "[" "$incoming in" "] [" "$outgoing out" "] [" "$rpc rpc" "] [white: " "$result_white_peerlist_size" "] [grey: " "$result_grey_peerlist_size" "]"
	}
	status_Template
}

status_P2Pool()
{
	define_P2Pool
	EXTRA_STATS()
	{
		# Get p2pool.log into memory.
		local LOG=$(tac $DIRECTORY/p2pool.log)
		# ONLY look for logs after p2pool is fully synced.
		local SYNC_STATUS=$(echo "$LOG" | grep -m1 "SYNCHRONIZED")

		if [[ $SYNC_STATUS = *"SYNCHRONIZED"* ]]; then
			# Get time of sync (read wall of text below for reason)
			local SYNC_DAY="$(echo "$SYNC_STATUS" | grep -o "..-..-..")"
			local SYNC_TIME="$(echo "$SYNC_STATUS" | grep -o "..:..:..")"
			local SYNC_1ST="$SYNC_DAY ${SYNC_TIME}"
			LOG="$(sed -n "/${SYNC_STATUS}/,/*/p" $DIRECTORY/p2pool.log)"

		# Return error if P2Pool is not synced yet.
		else
			# Return RPC error message if found
			if RPC_LOG=$(echo "$LOG" | grep -o -m1 "2.*get_info RPC request failed.*$"); then
				printf "\e[1;91m%s\e[0;97m%s\e[0m\n" "Warning | " "$RPC_LOG"
				printf "\e[1;91m%s\e[0;93m%s\e[0m\n" "Warning | " "P2Pool failed to connect to [$DAEMON_IP]'s RPC server!"
				printf "\e[1;91m%s\e[0;93m%s\e[0m\n" "Warning | " "Is [$DAEMON_RPC] in [p2pool.conf] the correct port?"
				return 1
			# Return ZMQ error message if found
			elif ZMQ_LOG=$(echo "$LOG" | grep -o -m1 "2.*ZMQReader failed to connect to.*$"); then
				printf "\e[1;91m%s\e[0;97m%s\e[0m\n" "Warning | " "$ZMQ_LOG"
				printf "\e[1;91m%s\e[0;93m%s\e[0m\n" "Warning | " "P2Pool failed to connect to [$DAEMON_IP]'s ZMQ server!"
				printf "\e[1;91m%s\e[0;93m%s\e[0m\n" "Warning | " "Is [$DAEMON_ZMQ] in [p2pool.conf] the correct port?"
				return 1
			# Else, normal error
			else
				printf "\e[1;91m%s\e[1;93m%s\e[0m\n" "Warning | " "P2Pool is not fully synced yet!"
				return 1
			fi
		fi

		# P2Pool allowing miner connections during sync causes fake stats
		# ---------------------------------------------------------------
		# If you have miners already pointed at p2pool while it's syncing,
		# it will send jobs to those miners, even though it's still syncing.
		# These jobs aren't "fake" but they do cause distorted stats.
		# (e.g.: SHARE FOUND message on a non-mainchain job).
		#
		# P2Pool doesn't ignore the old jobs even AFTER SYNCING.
		# So if you get unlucky and P2Pool gets a share within the same
		# milliseconds as syncing (which is easy since you're the only
		# miner on your personal chain, and almost guaranteed when there's
		# network latency involved), you'll get something like this:
		#
		# 2022-08-14 15:58:09.2753 SideChain SYNCHRONIZED           <--- okay, we're synced? time to parse from here!
		# 2022-08-14 15:58:09.3276 SHARE FOUND: mainchain ...       <--- wow, we found a share within 0.05 seconds!
	    # 2022-08-14 15:58:09.3315 SHARE FOUND: mainchain ...            these have to be real shares we found since
		#                                                                we synced already, right...? RIGHT SCHERNYKH...!?
		#
		# How am I supposed to know if these shares are "real" or not?
		# They are after the "SYNCHRONIZED" message but they aren't real.
		# P2Pool doesn't discard these shares after syncing, so when you type
		# in 'status', it'll show you are synced with the mainchain, and that
		# you found 2 shares (but not that those 2 aren't mainchain shares!):
		#
		# Side chain ID             = default           <-- you are synced with the main-chain
		# Side chain height         = 2xxxxxx
		# Side chain hashrate       = 1xx.xxx MH/s
		# Your shares position      = [2.........]      <-- these were found before you synced
		# Shares found              = 2                     but p2pool doesn't tell you that
		#
		# Technically these shares aren't "fake", they can be real Monero hashes,
		# but they probably shouldn't be lumped together with the mainchain stats.
		#
		# After p2pool syncs, it'll start sending "real" mainchain jobs to
		# the miners so this issue is only prevalent before being synced,
		# and for a few seconds after the inital sync (old jobs coming in)
		#
		# Some others mentioning this "bug":
		#     - https://github.com/SChernykh/p2pool/issues/154
		#     - https://github.com/SChernykh/p2pool/issues/185
		#
		# SChernykh's reply:
		#     - "It's a rare situation for such computer to even
		#        find a share, let alone find it at the exact time
		#        p2pool gets synchronized and resets counters."
		#
		# But Mr.Chernykh... this happens every time I start p2pool :)
		#
		# The fake share parsing fix:
		#     1. Parse the time of the SYNCHRONIZED msg
		#     2. Get the NEXT second after that initial time
		#     3. Account for any time overflows (23:59:59 -> 00:00:00)
		#     4. Delete any lines that contain those (2 second) timestamps
		#
		# 2 seconds should be a big enough margin to delete the fake shares,
		# and small enough to not clobber any real shares found.
		#
		# $SYNC_TIME   = sync timestamp
		# $SYNC_TIME_2 = 1 second after

		# Update: 2022-08-15
		# ------------------
		# I assumed P2Pool's local API would show the same
		# "fake" data as well so I didn't bother to check
		# but it seems like it only counts mainchain shares.
		# For some reason the API gets a different feed of
		# data than the console 'status' does. Anyway, I'll just
		# take 'shares_found' from there because it's better than
		# whatever the hell I wrote below. It also has other stats
		# I could include I guess (hashrate, effort, connections)

		# Update: 2022-08-15 10 minutes later
		# -----------------------------------
		# I lied. The API data also gets distorted by the
		# sub-second "fake" shares coming in at sync time.
		# Looks like we're using this code after all.
		# Note: We can also reset the EFFORT % with this
		# accurate share data, if shares found = 0, then
		# average_effort MUST also be 0.
		# I'll keep the API data around if the user set
		# the LOG_LEVEL = 0, then we can supply at least
		# SOME amount of information (even if it's inaccurate)

		# 22:22:22 -> 22 22 22
		SYNC_SPACE=(${SYNC_DAY//-/ } ${SYNC_TIME//:/ })
		# Back into string because it's easier to read
		local SYNC_YEAR=${SYNC_SPACE[0]} SYNC_MONTH=${SYNC_SPACE[1]} SYNC_DAY=${SYNC_SPACE[2]} SYNC_HOUR=${SYNC_SPACE[3]} SYNC_MINUTE=${SYNC_SPACE[4]} SYNC_SECOND=${SYNC_SPACE[5]}

        # Account for overflow (23:59:59 -> 00:00:00)
		# Second
        if [[ $SYNC_SECOND = 59 ]]; then
            SYNC_SECOND=00
            # Bash ((n++)) doesn't like leading 0's so use AWK
            SYNC_MINUTE=$(echo "$SYNC_MINUTE" | awk '{print $1 + 1}')
            # Add back leading 0's (awk strips them)
            [[ ${#SYNC_MINUTE} = 1 ]] && SYNC_MINUTE="0${SYNC_MINUTE}"
        else
            SYNC_SECOND=$(echo "$SYNC_SECOND" | awk '{print $1 + 1}')
            [[ ${#SYNC_SECOND} = 1 ]] && SYNC_SECOND="0${SYNC_SECOND}"
        fi
		# Minute
        if [[ $SYNC_MINUTE = 60 ]]; then
            SYNC_MINUTE=00
            SYNC_HOUR=$(echo "$SYNC_HOUR" | awk '{print $1 + 1}')
        fi
		# Hour
        if [[ $SYNC_HOUR = 24 ]]; then
            SYNC_HOUR=00
            SYNC_DAY=$(echo "$SYNC_DAY" | awk '{print $1 + 1}')
		fi
		# Days
		# Yes, I realize some months are less than 31 days.
		# I'm not going write code to figure that out,
		# the overflow reaching all the way here probably
		# won't happen that often enough anyway :)
		if [[ $SYNC_DAY = 32 ]]; then
			SYNC_DAY=01
			SYNC_MONTH=$(echo "$SYNC_MONTH" | awk '{print $1 + 1}')
		fi
		# Months
		if [[ $SYNC_MONTH = 13 ]]; then
			SYNC_MONTH=01
			SYNC_YEAR=$(echo "$SYNC_YEAR" | awk '{print $1 + 1}')
		fi

		# Our 2nd timetamp
		SYNC_2ND="${SYNC_YEAR}-${SYNC_HOUR}-${SYNC_DAY} ${SYNC_HOUR}:${SYNC_MINUTE}:${SYNC_SECOND}"

		# Delete all lines within 2 seconds of initial SYNC
		LOG="$(echo "$LOG" | sed "/${SYNC_1ST}/d; /${SYNC_2ND}/d")"

		# Okay, we're good.
		# Hopefully we can parse properly now.
		#
		# Reminder: all of this breaks down if
		# Mr.Chernykh decides to change any
		# keywords or the 24h timing scheme.




		# Warn if no p2poolApi file was found.
		if [[ ! -e $p2poolApi ]]; then
			print_Warn "P2Pool API file was not found, stats will be inaccurate!"
			print_Warn "Consider restarting P2Pool. It will regenerate necessary files."
		else
			# turn 'stats' p2pool JSON values into variables.
			# this uses: https://github.com/hinto-janaiyo/libjson
			# redirect error to /dev/null because sometimes
			# the stat file is empty
			local P2POOL_API_DATA=$(json::var < $p2poolApi 2>/dev/null)
			# [2022-09-13]
			# variable must be checked because sometimes the p2pool
			# API file is empty which leads to the bottom evaluating
			# into [local ] which will list variables interactively
			# to the user instead of doing anything
			[[ $P2POOL_API_DATA ]] && local $P2POOL_API_DATA
		fi

		local sharesFound sharesFoundApi sharesFoundLog latestPayout latestShare IFS=' '
		# SHARES FOUND
		case $LOG_LEVEL in
			0)
				sharesFoundLog="$(echo "$LOG" | grep -c "SHARE FOUND")"
				# if api shares != log shares, i'm trusting my own data over the api, sorry mr.chernykh
				[[ $shares_found = "$sharesFoundLog" ]] && sharesFound="$shares_found" || sharesFound="$sharesFoundLog"
				;;
			*)
				sharesFound="$(echo "$LOG" | grep -c "SHARE FOUND")";;
		esac
		[[ $sharesFound = 0 ]] && average_effort=0
		# DEFAULT TO 0
		[[ $sharesFound ]]    || sharesFound=0
		[[ $hashrate_15m ]]   || hashrate_15m=0
		[[ $hashrate_1h ]]    || hashrate_1h=0
		[[ $hashrate_24h ]]   || hashrate_24h=0
		[[ $average_effort ]] || average_effort=0
		[[ $current_effort ]] || current_effort=0
		[[ $connections ]]    || connections=0

		local xmrColumn processSeconds sharesPerHour sharesPerDay payoutTotal payoutPerHour payoutPerDay xmrTotal xmrPerHour xmrPerDay
		# process second calculation (reuses PROCESS_ID from status_Template())
		processSeconds=$(ps -p $PROCESS_ID -o etimes=)

		# AWK LIST
		xmrColumn=$(echo "$LOG" | grep -o "You received a payout of [0-9]\+.[0-9]\+ XMR")
		xmrColumn=${xmrColumn//[!0-9.$'\n']}
		if [[ $xmrColumn ]]; then
			payoutTotal=$(echo "$xmrColumn" | wc -l)
			# create awk list of shares, xmr column
			# [0] sharesPerHour
			# [1] sharesPerDay
			# [2] sharesPerMonth
			# [3] sharesPerYear
			# [4] payoutPerHour
			# [5] payoutPerDay
			# [6] payoutPerMonth
			# [7] payoutPerYear
			# [8] xmrTotal
			# [9] xmrPerHour
			# [10] xmrPerDay
			# [11] xmrPerMonth
			# [12] xmrPerYear
			xmrColumn=$(echo "$xmrColumn" | awk '{SUM+=$1}END{printf "%.7f", SUM}')
			local -a awkList=($(echo "$sharesFound" "$processSeconds" "$payoutTotal" "$xmrColumn" | awk '{printf "%.7f %.7f %.7f %.7f %.7f %.7f %.7f %.7f %.7f %.7f %.7f %.7f %.7f", $1/($2/60/60), ($1/($2/60/60))*24, (($1/($2/60/60))*24)*31, (($1/($2/60/60))*24)*365, $3/($2/60/60), ($3/($2/60/60))*24, (($3/($2/60/60))*24)*31, (($3/($2/60/60))*24)*365, $4, $4/($2/60/60), ($4/($2/60/60))*24, (($4/($2/60/60))*24)*31, (($4/($2/60/60))*24)*365}'))
			local -n sharesPerHour=awkList[0] sharesPerDay=awkList[1] sharesPerMonth=awkList[2] sharesPerYear=awkList[3] payoutPerHour=awkList[4] payoutPerDay=awkList[5] payoutPerMonth=awkList[6] payoutPerYear=awkList[7]  xmrTotal=awkList[8] xmrPerHour=awkList[9] xmrPerDay=awkList[10] xmrPerMonth=awkList[11] xmrPerYear=awkList[12]
		else
			local -a awkList=($(echo "$sharesFound" "$processSeconds" | awk '{printf "%.7f %.7f", $1/($2/60/60), ($1/($2/60/60))*24}'))
			local -n sharesPerHour=awkList[0] sharesPerDay=awkList[1] sharesPerMonth=awkList[2] sharesPerYear=awklist[3]
			[[ $sharesPerHour = 0* ]]  && sharesPerHour=0
			[[ $sharesPerDay = 0* ]]   && sharesPerDay=0
			[[ $sharesPerMonth = 0* ]] && sharesPerMonth=0
			[[ $sharesPerYear = 0* ]]  && sharesPerYear=0
			payoutTotal=0
			payoutPerHour=0
			payoutPerDay=0
			payoutPerMonth=0
			payoutPerYear=0
			xmrColumn=0
			xmrTotal=0
			xmrPerHour=0
			xmrPerDay=0
			xmrPerMonth=0
			xmrPerYear=0
		fi

		# print WALLET
		# Backwards compatibility with [monero-bash.conf]
		if [[ -z $WALLET ]]; then
			if WALLET=$(grep -E "^WALLET=(|'|\")4.*$" "$config/monero-bash.conf"); then
				WALLET=${WALLET//\'}
				WALLET=${WALLET//\"}
				WALLET=${WALLET/*=}
				print_Warn "[WALLET] not found in [p2pool.conf]"
				print_Warn "Falling back to [monero-bash.conf]'s [${WALLET:0:6}...${WALLET:89:95}]"
			else
				print_Warn "[WALLET] not found in [p2pool.conf]"
				print_Warn "[WALLET] not found in [monero-bash.conf]"
			fi
		fi
		printf "${BWHITE}%s${OFF}%s${IRED}%s${OFF}%s${IRED}%s${OFF}%s\n" "Wallet        | " "[" "${WALLET:0:6}" "..." "${WALLET: -6}" "]"

		# print EFFORT
		printf "${BWHITE}%s${OFF}%s${IWHITE}%s${OFF}%s${IWHITE}%s${OFF}%s\n" "Effort        | " "[average: " "${average_effort}%" "] [current: " "${current_effort}%" "]"

		# print HASHRATE
		printf "${BWHITE}%s\e[0m[\e[0;93m%s\e[0m%s\e[0;94m%s\e[0m%s\e[0;95m%s\e[0m] \e[0m[\e[0;93m%s\e[0m] \e[0m[\e[0;94m%s\e[0m] \e[0m[\e[0;95m%s\e[0m]\n" \
			"Hashrate      | " "15s" "/" "1h" "/" "24h" "$hashrate_15m H/s" "$hashrate_1h H/s" "$hashrate_24h H/s"


		# print CONNECTIONS
		[[ -e $MB_API/mini_now ]] && local SIDECHAIN="P2Pool Mini" || local SIDECHAIN="P2Pool Main"
		printf "${BWHITE}%s${OFF}%s${IWHITE}%s${OFF}%s${IWHITE}%s${OFF}%s\n${BWHITE}%s\n" \
		"Connection    | " "[miners: " "${connections}" "] [sidechain: " "${SIDECHAIN}" "]" "--------------| "

		# print SHARES FOUND
		printf "${BPURPLE}%s\e[0m%s\e[0;95m%s\e[0m%s\e[0;97m%s\e[0m%s\e[0;93m%s\e[0m%s\e[0;97m%s\e[0m%s\e[0;94m%s\e[0m%s${IWHITE}%s${OFF}%s${IPURPLE}%s${OFF}%s${IWHITE}%s${OFF}%s${IRED}%s${OFF}%s\n" \
			"Shares found  | " \
			"[" \
			"$sharesFound shares" \
			"] [" \
			"${sharesPerHour:0:9}" \
			"/" \
			"hour" \
			"] [" \
			"${sharesPerDay:0:9}" \
			"/" \
			"day" \
			"] [" \
			"${sharesPerMonth:0:9}" \
			"/" \
			"month" \
			"] [" \
			"${sharesPerYear:0:9}" \
			"/" \
			"year" \
			"]"

		# print PAYOUTS FOUND
		printf "${BCYAN}%s\e[0m%s\e[0;96m%s\e[0m%s\e[0;97m%s\e[0m%s\e[0;93m%s\e[0m%s\e[0;97m%s\e[0m%s\e[0;94m%s\e[0m%s${IWHITE}%s${OFF}%s${IPURPLE}%s${OFF}%s${IWHITE}%s${OFF}%s${IRED}%s${OFF}%s\n" \
			"Total payouts | " \
			"[" \
			"$payoutTotal payouts" \
			"] [" \
			"${payoutPerHour:0:9}" \
			"/" \
			"hour" \
			"] [" \
			"${payoutPerDay:0:9}" \
			"/" \
			"day" \
			"] [" \
			"${payoutPerMonth:0:9}" \
			"/" \
			"month" \
			"] [" \
			"${payoutPerYear:0:9}" \
			"/" \
			"year" \
			"]"

		# print XMR
		printf "${BGREEN}%s\e[0m%s\e[0;92m%s\e[0m%s\e[0;97m%s\e[0m%s\e[0;93m%s\e[0m%s\e[0;97m%s\e[0m%s\e[0;94m%s\e[0m%s${IWHITE}%s${OFF}%s${IPURPLE}%s${OFF}%s${IWHITE}%s${OFF}%s${IRED}%s${OFF}%s\n" \
			"XMR received  | " \
			"[" \
			"$xmrTotal XMR" \
			"] [" \
			"${xmrPerHour:0:9}" \
			"/" \
			"hour" \
			"] [" \
			"${xmrPerDay:0:9}" \
			"/" \
			"day" \
			"] [" \
			"${xmrPerMonth:0:9}" \
			"/" \
			"month" \
			"] [" \
			"${xmrPerYear:0:9}" \
			"/" \
			"year" \
			"]"

		# print LATEST SHARE
		declare -a latestShare=($(echo "$LOG" | tac | grep -m1 "SHARE FOUND"))
		# [0] = NOTICE
		# [1] = 20xx-xx-xx
		# [2] = xx:xx:xx.xxxx
		# [3] = StratumServer
		# [4] = SHARE
		# [5] = FOUND:
		# [6] = mainchain
		# [7] = height
		# [8] = (int),
		# [9] = diff
		# [10] = (int),
		# [11] = client
		# [12] = (ip:port) (with no comma...!???)
		# [13] = user
		# [14] = (user),
		# [15] = effort
		# [16] = xx.xxx%
		[[ ${latestShare[14]} = ',' || "" ]] && latestShare[14]=???
		if [[ $latestShare ]]; then
			printf "${BBLUE}%s${OFF}%s${IWHITE}%s${OFF}%s${IWHITE}%s${OFF}%s${IWHITE}%s${OFF}%s${IWHITE}%s${OFF}%s${IWHITE}%s${OFF}%s\n" \
				"Latest share  | " "[" "${latestShare[1]} ${latestShare[2]//.*}" "] [block: " "${latestShare[8]:0:-1}" "] [user: " "${latestShare[14]:0:-1}" "/" "${latestShare[12]}" "] [effort: " "${latestShare[16]}" "]"
		else
			printf "${BBLUE}%s\n" "Latest share  | "
		fi

		# print LATEST PAYOUT
		declare -a latestPayout=($(echo "$LOG" | tac | grep -m1 "You received a payout"))
		# [0] = NOTICE
		# [1] = 20xx-xx-xx
		# [2] = xx:xx:xx.xxxx
		# [3] = P2Pool
		# [4,5,6,7,8] = You received a payout of
		# [9] = x.xxxxxxxxxxxx
		# [10,11,12] = XMR in block
		# [13] = (int)
		if [[ $latestPayout ]]; then
			printf "${BYELLOW}%s${OFF}%s${IWHITE}%s${OFF}%s${IWHITE}%s${OFF}%s${IWHITE}%s${OFF}%s\n" \
				"Latest payout | " "[" "${latestPayout[1]} ${latestPayout[2]//.*}" "] [block: " "${latestPayout[13]}" "] [" "${latestPayout[9]} XMR" "]"
		else
			printf "${BYELLOW}%s${OFF}\n" "Latest payout | "
		fi
	}
	status_Template
}

status_XMRig()
{
	define_XMRig
	EXTRA_STATS()
	{
		if [[ -e $binXMRig/xmrig-log ]]; then
			local LOG=$(tac $binXMRig/xmrig-log)
			local CONF=$(<${xmrigConf})
			# this is for getting runtime settings of
			# [xmrig.conf] but its a little too slow and
			# it doesn't get very interesting stats.
			# [status] goes from [0.6sec] -> [1sec]
			# so probably not worth it.
#			local $(json::var < $xmrigConf | grep "url\|user\|randomx\|cpu_huge-pages\|cpu_huge-pages-jit" | tr '-' '_') 2>/dev/null
		else
			print_Warn "[$binXMRig/xmrig-log] was not found, can't get XMRig stats!"
		fi

		# POOL
		local pool=$(echo "$CONF" | grep -m1 "url")
		pool=${pool/*: }
		pool=${pool//\"}
		pool=${pool//,}
		printf "${BPURPLE}%s${OFF}%s${IPURPLE}%s${OFF}%s\n" "Pool         | " "[" "${pool}" "]"

		# WALLET (in xmrig.json)
		local wallet=$(echo "$CONF" | grep -m1 "user")
		wallet=${wallet/*: }
		wallet=${wallet//\"}
		wallet=${wallet//,}
		printf "${BWHITE}%s${OFF}%s${IRED}%s${OFF}%s${IRED}%s${OFF}%s\n" "Wallet       | " "[" "${wallet:0:6}" "..." "${wallet: -6}" "]"

#		# RANDOMX SETTINGS
#		printf "${BGREEN}%s${OFF}%s${IWHITE}%s${OFF}%s${IWHITE}%s${OFF}%s${IWHITE}%s${OFF}%s${IWHITE}%s${OFF}%s${IWHITE}%s${OFF}%s\n" "RandomX      | " \
#			"[1gb-pages: " "$randomx_1gb_pages" "] [hugepages: " "$cpu_huge_pages" "] [jit: " "$cpu_huge_pages_jit" \
#			"] [rdmsr: " "$randomx_rdmsr" "] [wrmsr: " "$randomx_wrmsr" "]"

		# HASHRATE
		declare -a hashrate=($(echo "$LOG" | grep -m1 "speed"))
		# [0] = [day
		# [1] = time]
		# [2, 3] = miner speed
		# [4] = 10s/60s/15m
		# [5,6,7] = #.# #.# #.# (or n/a)
		if [[ $hashrate ]]; then
			printf "${BYELLOW}%s${OFF}%s${IYELLOW}%s${OFF}%s${IBLUE}%s${OFF}%s${BPURPLE}%s${OFF}%s${IYELLOW}%s${OFF}%s${IBLUE}%s${OFF}%s${IPURPLE}%s${OFF}%s\n" \
				"Hashrate     | " "${hashrate[0]} ${hashrate[1]} [" "10s" "/" "60s" "/" "15m" "] [" "${hashrate[5]} H/s" "] [" "${hashrate[6]} H/s" "] [" "${hashrate[7]} H/s" "]"
		else
			printf "${BYELLOW}%s${OFF}\n" "Hashrate     | "
		fi

		# ACCEPTED SHARES
		declare -a shares=($(echo "$LOG" | grep -m1 "accepted"))
		# [0] = [day
		# [1] = time]
		# [2] = cpu
		# [3] = accepted
		# [4] = (#/#)
		# [5] = diff
		# [6] = #
		# [7] = (#
		# [8] = ms)
		if [[ $shares ]]; then
			printf "${BBLUE}%s${OFF}%s${IGREEN}%s${OFF}%s${IRED}%s${OFF}%s\n" "Latest share | " \
				"${shares[0]} ${shares[1]} [" "accepted: ${shares[4]}" "] [" "diff: ${shares[6]}" "] ${shares[7]} ${shares[8]}"
		else
			printf "${BBLUE}%s${OFF}\n" "Latest share | "
		fi
	}
	status_Template
}
