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


# status function, prints multiple helpful stats

status_All()
{
	print_MoneroBashTitle
	print_Version
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
	BBLUE; printf "System      | "
	IWHITE; echo "$(uptime -p)"
	echo
}

status_Template()
{
	BWHITE; printf "[${NAME_PRETTY}] " ;OFF
	if pgrep $DIRECTORY/$PROCESS -f &>/dev/null ;then
		BGREEN; echo "ONLINE" ;OFF

		# ps stats
		ps -o "| %C | %t |" -p $(pgrep $DIRECTORY/$PROCESS -f)
		echo "----------------------"
		# process specific stats
		EXTRA_STATS
		echo
	else
		BRED; echo "OFFLINE" ;OFF
		echo
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

		# 2022-08-17
		# ----------
		# [monerod status] doesn't work if the
		# ip:port isn't localhost:18081 anyway,
		# so just don't even try using it.

#		elif ! GET_INFO=$(wget -qO- "localhost:18081/json_rpc" --header='Content-Type:application/json' --post-data='{"jsonrpc":"2.0","id":"0","method":"get_info"}'); then
#			if [[ -z $GET_INFO || $GET_INFO = *error* ]]; then
#				print_Warn "[DAEMON_RPC_IP] not found in [monero-bash.conf]"
#				print_Warn "[rpc-bind-ip] and/or [rpc-bind-port] not found in [monerod.conf]"
#				print_Warn "Local fallback [localhost:18081] did not work!"
#				print_Warn "Falling back to (slow) local invoking of [monerod status]"
#				# [monerod status fallback]
#				# Get into memory so we can split it
#				# (the regular output is ugly long)
#				local STATUS="$($binMonero/monerod status)"
#				# Split per newline
#				local IFS=$'\n' LINE l=0
#				for i in $STATUS; do
#					LINE[$l]="$i"
#					((l++))
#				done
#				# This removes the ANSI color codes in monerod output
#				LINE[0]="$(echo "${LINE[0]}" | sed 's/\x1B\[[0-9;]\{1,\}[A-Za-z]//g; s/[^[:print:]]//g')"
#				printf "\e[0;96m%s\e[0m\n" "${LINE[0]}"
#
#				# Split this line into 2
#				LINE[1]="$(echo "${LINE[1]}" | sed 's/\x1B\[[0-9;]\{1,\}[A-Za-z]//g; s/[^[:print:]]//g; s/, net hash/\nnet hash/')"
#				# Replace ',' with '|' and add color
#				echo -e "\e[0;92m${LINE[1]//, /\\e[0;97m | \\e[0;92m}\e[0m"
#				return

		# [localhost:18081] fallback
		else
			DAEMON_RPC_IP=localhost:18081
			print_Warn "[DAEMON_RPC_IP] not found in [monero-bash.conf]"
			print_Warn "[rpc-bind-ip] and/or [rpc-bind-port] not found in [monerod.conf]"
			print_Warn "Falling back to [localhost:18081]"
		fi
		GET_INFO=$(wget -qO- "localhost:18081/json_rpc" --header='Content-Type:application/json' --post-data='{"jsonrpc":"2.0","id":"0","method":"get_info"}')
		if [[ $? != 0 || -z $GET_INFO || $GET_INFO = *error* ]]; then
			printf "\e[1;91m%s\e[0;97m%s\e[0m\n" "Warning | " "Could not connect to [$DAEMON_RPC_IP] to get Monero stats!"
			return 1
		fi

		# filter 'get_info' rpc call
		local height height_percent percent_color incoming outgoing rpc synchronized nettype synchronized target_height tx_pool_size net_hash database_size
		height=$(echo "$GET_INFO" | grep "\"height\":")
		height=${height//[!0-9]}
		target_height=$(echo "$GET_INFO" | grep "\"target_height\":")
		target_height=${target_height//[!0-9]}
		incoming=$(echo "$GET_INFO" | grep "\"incoming_connections_count\":")
		incoming=${incoming//[!0-9]}
		outgoing=$(echo "$GET_INFO" | grep "\"outgoing_connections_count\":")
		outgoing=${outgoing//[!0-9]}
		rpc=$(echo "$GET_INFO" | grep "\"rpc_connections_count\":")
		rpc=${rpc//[!0-9]}
		synchronized=$(echo "$GET_INFO" | grep "\"synchronized\":")
		if [[ $synchronized = *true* ]]; then
			target_height=$height
			height_percent="100"
		else
			height_percent=$(echo "$height" "$target_height" | awk '{print $1 / $2 * 100}')
			height_percent=${height_percent:0:5}
		fi
		height_percent_int=${height_percent//.*}
		if [[ $height_percent = 100 ]]; then
			percent_color="\e[92m"
		elif [[ $height_percent_int -le 30 ]]; then
			percent_color="\e[91m"
		else
			percent_color="\e[93m"
		fi
		nettype=$(echo "$GET_INFO" | grep "\"nettype\":")
		nettype=${nettype//*:}
		nettype=${nettype//[![:alnum:]]}
		tx_pool_size=$(echo "$GET_INFO" | grep "\"tx_pool_size\":")
		tx_pool_size=${tx_pool_size//[!0-9]}
		net_hash=$(echo "$GET_INFO" | grep "\"difficulty\":")
		net_hash=${net_hash//[!0-9]}
		net_hash=$(echo "$net_hash" | awk '{print $1 / 120000000000}')
		database_size=$(echo "$GET_INFO" | grep "\"database_size\":")
		database_size=${database_size//[!0-9]}
		database_size=$(echo "$database_size" | awk '{print $1 / 1000000000}')

		# print
		BWHITE; printf "Size        | "; printf "\e[0m%s\e[97m%s\e[0m%s\n" "[" "$database_size GB" "]"
		BWHITE; printf "Height      | "; printf "\e[0m%s${percent_color}%s\e[0m%s\e[92m%s\e[0m%s${percent_color}%s\e[0m%s\e[96m%s\e[0m%s\n" \
			"[" "$height" "/" "$target_height" "] (" "${height_percent}%" ") on [" "$nettype" "]"
		BWHITE; printf "TX Pool     | "; printf "\e[0m%s\e[95m%s\e[0m%s\n" "[" "$tx_pool_size" "]"
		BWHITE; printf "Net Hash    | "; printf "\e[0m%s\e[94m%s\e[0m%s\n" "[" "$net_hash GH/s" "]"
		BWHITE; printf "Connections | "; printf "\e[0m%s\e[93m%s\e[0m%s\e[92m%s\e[0m%s\e[91m%s\e[0m%s\n" "[" "$incoming in" "] [" "$outgoing out" "] [" "$rpc rpc" "]"
	}
	status_Template
}

status_P2Pool()
{
	define_P2Pool
	EXTRA_STATS()
	{
		# Get p2pool.log into memory.
		# Also ONLY look for logs after
		# p2pool is fully synced.
		local LOG="$(tac $DIRECTORY/p2pool.log | grep -m1 "SideChain SYNCHRONIZED")"
		# Get time of sync (read wall of text for reason)
		local SYNC_DAY="$(echo "$LOG" | grep -o "..-..-..-")"
		local SYNC_TIME="$(echo "$LOG" | grep -o "..:..:..")"
		local SYNC_1ST="$SYNC_DAY ${SYNC_TIME}"

		# Return error if P2Pool is not synced yet.
		if [[ $LOG != *"SideChain SYNCHRONIZED"* ]]; then
			# Return RPC error message if found
			if RPC_LOG=$(tac $DIRECTORY/p2pool.log | grep -o -m1 "2.*get_info RPC request failed.*$"); then
				printf "\e[1;91m%s\e[0;97m%s\e[0m\n" "Warning | " "$RPC_LOG"
				printf "\e[1;91m%s\e[0;93m%s\e[0m\n" "Warning | " "P2Pool failed to connect to [$DAEMON_IP]'s RPC server!"
				printf "\e[1;91m%s\e[0;93m%s\e[0m\n" "Warning | " "Is [$DAEMON_RPC] in [p2pool.conf] the correct port?"
				return 1
			# Return ZMQ error message if found
			elif ZMQ_LOG=$(tac $DIRECTORY/p2pool.log | grep -o -m1 "2.*ZMQReader failed to connect to.*$"); then
				printf "\e[1;91m%s\e[0;97m%s\e[0m\n" "Warning | " "$ZMQ_LOG"
				printf "\e[1;91m%s\e[0;93m%s\e[0m\n" "Warning | " "P2Pool failed to connect to [$DAEMON_IP]'s ZMQ server!"
				printf "\e[1;91m%s\e[0;93m%s\e[0m\n" "Warning | " "Is [$DAEMON_ZMQ] in [p2pool.conf] the correct port?"
				return 1
			# Else, normal error
			else
				printf "\e[1;91m%s\e[1;93m%s\e[0m\n" "Warning | " "P2Pool is not fully synced yet!"
				return 1
			fi
		else
			LOG="$(sed -n "/$LOG/,/*/p" $DIRECTORY/p2pool.log)"
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
		local SYNC_YEAR=${SYNC_SPACE[0]}
		local SYNC_MONTH=${SYNC_SPACE[1]}
		local SYNC_DAY=${SYNC_SPACE[2]}
        local SYNC_HOUR=${SYNC_SPACE[3]}
        local SYNC_MINUTE=${SYNC_SPACE[4]}
        local SYNC_SECOND=${SYNC_SPACE[5]}

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
		fi

		local sharesFound p2pHash_15m p2pHash_1h p2pHash_24h averageEffort currentEffort connections
		# SHARES FOUND
		case $LOG_LEVEL in
			0)
				sharesFound=$(grep -o "\"shares_found\":[0-9]\+" $p2poolApi 2>/dev/null)
				sharesFound=${sharesFound//*:};;
			*)
				sharesFound="$(echo "$LOG" | grep -c "SHARE FOUND")";;
		esac
		# HASHRATE
		p2pHash_15m=$(grep -o "\"hashrate_15m\":[0-9]\+\|\"hashrate_15m\":[0-9]\+.[0-9]\+" $p2poolApi 2>/dev/null)
		p2pHash_1h=$(grep -o "\"hashrate_1h\":[0-9]\+\|\"hashrate_1h\":[0-9]\+.[0-9]\+" $p2poolApi 2>/dev/null)
		p2pHash_24h=$(grep -o "\"hashrate_24h\":[0-9]\+\|\"hashrate_24h\":[0-9]\+.[0-9]\+" $p2poolApi 2>/dev/null)
		p2pHash_15m=${p2pHash_15m//*:}
		p2pHash_1h=${p2pHash_1h//*:}
		p2pHash_24h=${p2pHash_24h//*:}
		# EFFORT
		averageEffort=$(grep -o "\"average_effort\":[0-9]\+\|\"average_effort\":[0-9]\+.[0-9]\+" $p2poolApi 2>/dev/null)
		currentEffort=$(grep -o "\"current_effort\":[0-9]\+\|\"current_effort\":[0-9]\+.[0-9]\+" $p2poolApi 2>/dev/null)
		averageEffort=${averageEffort//*:}
		currentEffort=${currentEffort//*:}
		[[ $sharesFound = 0 ]] && averageEffort=0
		# CONNECTIONS
		connections=$(grep -o "\"incoming_connections\":[0-9]\+" $p2poolApi 2>/dev/null)
		connections=${connections//*:}
		# DEFAULT TO 0
		[[ $sharesFound ]]   || sharesFound=0
		[[ $p2pHash_15m ]]   || p2pHash_15m=0
		[[ $p2pHash_1h ]]    || p2pHash_1h=0
		[[ $p2pHash_24h ]]   || p2pHash_24h=0
		[[ $averageEffort ]] || averageEffort=0
		[[ $currentEffort ]] || currentEffort=0
		[[ $connections ]]   || connections=0

		# XMR COLUMN
		local xmrColumn="$(echo "$LOG" | grep -o "You received a payout of [0-9]\+.[0-9]\+ XMR")"
		local xmrColumn="$(echo "$xmrColumn" | grep -o "[0-9]\+.[0-9]\+")"

		# hour calculation
		local processUnixTime="$(ps -p $(pgrep $DIRECTORY/$PROCESS -f) -o etimes=)"
		local processHours="$(echo "$processUnixTime" "60" "60" | awk '{printf "%.7f\n", $1 / $2 / $3 }')"
		[[ $processHours = 0 ]] && processHours="1"

		# day calculation
		local processDays="$(echo "$processHours" "24" | awk '{printf "%.7f\n", $1 / $2 }')"

		# SHARES/hour & SHARES/day
		local sharesPerHour="$(echo "$sharesFound" "$processHours" | awk '{printf "%.7f\n", $1 / $2 }')"
		local sharesPerDay="$(echo "$sharesFound" "$processDays" | awk '{printf "%.7f\n", $1 / $2 }')"

		# payout calculation
		if [[ $xmrColumn ]]; then
			local payoutTotal="$(echo "$xmrColumn" | wc -l)"
			local payoutPerHour="$(echo "$payoutTotal" "$processHours" | awk '{printf "%.7f\n", $1 / $2 }')"
			local payoutPerDay="$(echo "$payoutTotal" "$processDays" | awk '{printf "%.7f\n", $1 / $2 }')"
		else
			local payoutTotal=0
			local payoutPerHour=0.0000000
			local payoutPerDay=0.0000000
		fi
		# xmr calculation
		if [[ $xmrColumn ]]; then
			local xmrTotal="$(echo "$xmrColumn" | awk '{SUM+=$1}END{printf "%.7f\n", SUM }')"
			local xmrPerHour="$(echo "$xmrTotal" "$processHours" | awk '{printf "%.7f\n", $1 / $2 }')"
			local xmrPerDay="$(echo "$xmrTotal" "$processDays" | awk '{printf "%.7f\n", $1 / $2 }')"
		else
			local xmrTotal=0
			local xmrPerHour=0.0000000
			local xmrPerDay=0.0000000
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
		BWHITE; printf "Wallet        | "
		OFF; echo "[${WALLET:0:6}...${WALLET: -6}]"


		# print EFFORT
		BWHITE; printf "Effort        | "; OFF
		OFF; echo -n "[average: ${averageEffort}%] "
		OFF; echo "[current: ${currentEffort}%]"

		# print HASHRATE
		BWHITE; printf "Hashrate      | "; OFF
		printf "\e[0m[\e[0;93m%s\e[0m%s\e[0;94m%s\e[0m%s\e[0;95m%s\e[0m] " "15s" "/" "1h" "/" "24h"
		printf "\e[0m[\e[0;93m%s\e[0m] " "$p2pHash_15m H/s"
		printf "\e[0m[\e[0;94m%s\e[0m] " "$p2pHash_1h H/s"
		printf "\e[0m[\e[0;95m%s\e[0m]\n" "$p2pHash_24h H/s"

		# print SIDECHAIN
		BWHITE; printf "Side-Chain    | "
		if [[ -e $installDirectory/src/mini/mini_now ]]; then
			OFF; echo "[P2Pool Mini]"
		else
			OFF; echo "[P2Pool Main] (default)"
		fi

		# print CONNECTIONS
		BWHITE; printf "Connections   | "; OFF
		OFF; echo "[${connections}] "
		BWHITE; echo "--------------| "

		# print SHARES FOUND
		BPURPLE; printf "Shares found  | "
		printf "\e[0m%s\e[0;95m%s\e[0m%s\e[0;97m%s\e[0m%s\e[0;93m%s\e[0m%s\e[0;97m%s\e[0m%s\e[0;94m%s\e[0m%s\n" \
			"[" \
			"$sharesFound shares" \
			"] [" \
			"${sharesPerHour}" \
			"/" \
			"hour" \
			"] [" \
			"${sharesPerDay}" \
			"/" \
			"day" \
			"]"

		# print PAYOUTS FOUND
		BCYAN; printf "Total payouts | "
		printf "\e[0m%s\e[0;96m%s\e[0m%s\e[0;97m%s\e[0m%s\e[0;93m%s\e[0m%s\e[0;97m%s\e[0m%s\e[0;94m%s\e[0m%s\n" \
			"[" \
			"$payoutTotal payouts" \
			"] [" \
			"${payoutPerHour}" \
			"/" \
			"hour" \
			"] [" \
			"${payoutPerDay}" \
			"/" \
			"day" \
			"]"

		# print XMR
		BGREEN; printf "XMR received  | "
		printf "\e[0m%s\e[0;92m%s\e[0m%s\e[0;97m%s\e[0m%s\e[0;93m%s\e[0m%s\e[0;97m%s\e[0m%s\e[0;94m%s\e[0m%s\n" \
			"[" \
			"$xmrTotal XMR" \
			"] [" \
			"${xmrPerHour}" \
			"/" \
			"hour" \
			"] [" \
			"${xmrPerDay}" \
			"/" \
			"day" \
			"]"

		# print LATEST SHARE
		BBLUE; printf "Latest share  | "; OFF
		declare -a latestShare=($(echo "$LOG" | tac | grep -m1 "SHARE FOUND" | sed 's/mainchain //g; s/NOTICE .\|Stratum.*: //g; s/, diff .*, c/ c/; s/user.*, //'))
		# [0] = day
		# [1] = time
		# [2] = height
		# [3] = #
		# [4] = client
		# [5] = ip:port
		# [6] = effort
		# [7] = %
		if [[ $latestShare ]]; then
			latestShare[1]=${latestShare[1]//.*}
			echo -n "[${latestShare[0]} ${latestShare[1]}] [block ${latestShare[3]}] [${latestShare[4]} ${latestShare[5]}] [${latestShare[6]} ${latestShare[7]}]" || echo
		fi
		echo

		# print LATEST PAYOUT
		BYELLOW; printf "Latest payout | "; OFF
		declare -a latestPayout=($(echo "$LOG" | grep "You received a payout of" | tail -1 | sed 's/NOTICE  //; s/P2Pool //'))
		# [0] = day
		# [1] = time
		# [2,3,4,5,6] = You received a payout of
		# [7] = #
		# [8] = XMR
		# [9,10] = in block
		# [11] = #
		if [[ $latestPayout ]]; then
			latestPayout[1]=${latestPayout[1]//.*}
			echo -n "[${latestPayout[0]} ${latestPayout[1]}] [block ${latestPayout[11]}] [${latestPayout[7]} XMR]"
		fi
		echo
	}
	status_Template
}

status_XMRig()
{
	define_XMRig
	EXTRA_STATS()
	{
		# WALLET (in xmrig.json)
		BWHITE; printf "Wallet       | " ;OFF
		local wallet="$(grep -m1 "\"user\":" "$xmrigConf" | awk '{print $2}' | tr -d '", ')"
		[[ -z $wallet ]] && echo || echo "[${wallet:0:6}...${wallet: -6}]"

		# POOL
		BPURPLE; printf "Pool         | " ;OFF
		local xmrigPool=$(grep -m1 "\"url\":" "$xmrigConf" | awk '{print $2}' | tr -d '","')
		echo "[${xmrigPool}]"

		# SHARES
		declare -a shares=($(tac "$binXMRig/xmrig-log" | grep -m1 "accepted" | sed 's/[[:blank:]]\+cpu[[:blank:]]\+/ /'))
		# [0] = [day
		# [1] = time]
		# [2] = accepted
		# [3] = (#/#)
		# [4] = diff
		# [5] = #
		# [6] = (#
		# [7] = ms)
		BBLUE; printf "Latest share | "
		if [[ $shares ]]; then
			shares[1]=${shares[1]//.*/]}
			shares[3]=${shares[3]//(}
			shares[3]=${shares[3]//)}
			shares[6]=${shares[6]//(}
			shares[7]=${shares[7]//)}
			OFF; echo -n "${shares[0]} ${shares[1]} [${shares[2]} ${shares[3]}] [${shares[4]} ${shares[5]}] [${shares[6]} ${shares[7]}]"
		fi
		echo

		# HASHRATE
		declare -a hashrate=($(tac "$binXMRig/xmrig-log" | grep -m1 "speed" | sed 's|].*miner.*10s/60s/15m|]|'))
		# [0] = [day
		# [1] = time]
		# [2] = # or n/a
		# [3] = # or n/a
		# [4] = # or n/a
		# [5] = H/s
		# [6] = max
		# [7] = #
		# [8] = H/s
		BYELLOW; printf "Hashrate     | "
		if [[ $hashrate ]]; then
			hashrate[1]=${hashrate[1]//.*/]}
			OFF; echo -n "${hashrate[0]} ${hashrate[1]} "
			[[ ${hashrate[2]} != 'n/a' ]] && hashrate[2]="${hashrate[2]} H/s"
			[[ ${hashrate[3]} != 'n/a' ]] && hashrate[3]="${hashrate[3]} H/s"
			[[ ${hashrate[4]} != 'n/a' ]] && hashrate[4]="${hashrate[4]} H/s"
			printf "\e[0m[\e[0;93m%s\e[0m%s\e[0;94m%s\e[0m%s\e[0;95m%s\e[0m] " "10s" "/" "60s" "/" "15m"
			printf "\e[0m[\e[0;93m%s\e[0m] " "${hashrate[2]}"
			printf "\e[0m[\e[0;94m%s\e[0m] " "${hashrate[3]}"
			printf "\e[0m[\e[0;95m%s\e[0m]\n" "${hashrate[4]}"
		fi
		echo
	}
	status_Template
}
