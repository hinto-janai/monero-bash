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
	[[ $MONERO_VER != "" ]]&& status_Monero
	[[ $P2POOL_VER != "" ]]&& status_P2Pool
	[[ $XMRIG_VER != "" ]]&& status_XMRig
	exit 0
}

status_System()
{
	$bblue; printf "System      | "
	$iwhite; echo "$(uptime -p)"
	echo
}

status_Template()
{
	$bwhite; printf "[${NAME_PRETTY}] " ;$off
	if pgrep $DIRECTORY/$PROCESS -f &>/dev/null ;then
		$bgreen; echo "ONLINE" ;$off

		# ps stats
		ps -o "| %C | %t |" -p $(pgrep $DIRECTORY/$PROCESS -f)
		echo "----------------------"
		# process specific stats
		EXTRA_STATS
		echo
	else
		$bred; echo "OFFLINE" ;$off
		echo
	fi
}

status_Monero()
{
	define_Monero
	EXTRA_STATS()
	{
		# Get into memory so we can split it
		# (the regular output is ugly long)
		local STATUS="$($binMonero/monerod status)"
		# Split per newline
		local IFS=$'\n' LINE l=0
		for i in $STATUS; do
			LINE[$l]="$i"
			((l++))
		done
		# This removes the ANSI color codes in monerod output
		LINE[0]="$(echo "${LINE[0]}" | sed 's/\x1B\[[0-9;]\{1,\}[A-Za-z]//g; s/[^[:print:]]//g')"
		printf "\e[0;96m%s\e[0m\n" "${LINE[0]}"

		# Split this line into 2
		LINE[1]="$(echo "${LINE[1]}" | sed 's/\x1B\[[0-9;]\{1,\}[A-Za-z]//g; s/[^[:print:]]//g; s/, net hash/\nnet hash/')"
		# Replace ',' with '|' and add color
		echo -e "\e[0;92m${LINE[1]//, /\\e[0;97m | \\e[0;92m}\e[0m"
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
				printf "\e[1;91m%s\e[0;93m%s\e[0m\n" "Warning | " "P2Pool failed to connect to [monerod]'s RPC server!"
				printf "\e[1;91m%s\e[0;93m%s\e[0m\n" "Warning | " "Does [DAEMON_RPC] in [monero-bash.conf] match [rpc-bind-port] in [monerod.conf]?"
				return 1
			# Return ZMQ error message if found
			elif ZMQ_LOG=$(tac $DIRECTORY/p2pool.log | grep -o -m1 "2.*ZMQReader failed to connect to.*$"); then
				printf "\e[1;91m%s\e[0;97m%s\e[0m\n" "Warning | " "$ZMQ_LOG"
				printf "\e[1;91m%s\e[0;93m%s\e[0m\n" "Warning | " "P2Pool failed to connect to [monerod]'s ZMQ server!"
				printf "\e[1;91m%s\e[0;93m%s\e[0m\n" "Warning | " "Does [DAEMON_ZMQ] in [monero-bash.conf] match [zmq-pub] in [monerod.conf]?"
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




		# SHARE OUTPUT VARIABLE
		local shareOutput="$(echo "$LOG" | grep "SHARE FOUND")"
		# XMR COLUMN
		local xmrColumn="$(echo "$LOG" | grep -o "You received a payout of [0-9]\+.[0-9]\+ XMR")"
		local xmrColumn="$(echo "$xmrColumn" | grep -o "[0-9]\+.[0-9]\+")"

		# hour calculation
		if [[ -z $shareOutput ]]; then
			local sharesFound="0"
		else
			local sharesFound="$(echo "$shareOutput" | wc -l)"
		fi
		local processUnixTime="$(ps -p $(pgrep $DIRECTORY/$PROCESS -f) -o etimes=)"
		local processHours="$(echo "$processUnixTime" "60" "60" | awk '{printf "%.7f\n", $1 / $2 / $3}'))"
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
		$bwhite; printf "Wallet        | "
		$off; echo "${WALLET:0:6}...${WALLET: -6}"

		# print SHARES FOUND
		$bpurple; printf "Shares found  | "
		$ipurple; echo -n "$sharesFound shares "
		printf "\e[0m%s\e[0;97m%s\e[0m%s\e[0;93m%s\e[0m%s\e[0;97m%s\e[0m%s\e[0;94m%s\e[0m%s\n" \
			"[" \
			"${sharesPerHour}" \
			"/" \
			"hour" \
			"] [" \
			"${sharesPerDay}" \
			"/" \
			"day" \
			"]"

		# print PAYOUTS FOUND
		$bcyan; printf "Total payouts | "
		$icyan; echo -n "$payoutTotal payouts "
		printf "\e[0m%s\e[0;97m%s\e[0m%s\e[0;93m%s\e[0m%s\e[0;97m%s\e[0m%s\e[0;94m%s\e[0m%s\n" \
			"[" \
			"${payoutPerHour}" \
			"/" \
			"hour" \
			"] [" \
			"${payoutPerDay}" \
			"/" \
			"day" \
			"]"

		# print XMR
		$bgreen; printf "XMR received  | "
		$igreen; echo -n "$xmrTotal XMR "
		printf "\e[0m%s\e[0;97m%s\e[0m%s\e[0;93m%s\e[0m%s\e[0;97m%s\e[0m%s\e[0;94m%s\e[0m%s\n" \
			"[" \
			"${xmrPerHour}" \
			"/" \
			"hour" \
			"] [" \
			"${xmrPerDay}" \
			"/" \
			"day" \
			"]"

		# print LATEST SHARE
		$bblue; printf "Latest share  | "; $off
		declare -a latestShare=($(echo "$shareOutput" | tail -1 | sed 's/mainchain //g; s/NOTICE .\|Stratum.*: //g; s/, diff .*, c/ c/; s/user.*, //'))
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
		$byellow; printf "Latest payout | "; $off
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
		$bwhite; printf "Wallet       | " ;$off
		local wallet="$(grep -m1 "\"user\":" "$xmrigConf" | awk '{print $2}' | tr -d '", ')"
		[[ -z $wallet ]] && echo || echo "${wallet:0:6}...${wallet: -6}"

		# POOL
		$bpurple; printf "Pool         | " ;$off
		grep -m1 "\"url\":" "$xmrigConf" | awk '{print $2}' | tr -d '","'

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
		$bblue; printf "Latest share | "
		if [[ $shares ]]; then
			shares[1]=${shares[1]//.*/]}
			shares[3]=${shares[3]//(}
			shares[3]=${shares[3]//)}
			shares[6]=${shares[6]//(}
			shares[7]=${shares[7]//)}
			$off; echo -n "${shares[0]} ${shares[1]} [${shares[2]} ${shares[3]}] [${shares[4]} ${shares[5]}] [${shares[6]} ${shares[7]}]"
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
		$byellow; printf "Hashrate     | "
		if [[ $hashrate ]]; then
			hashrate[1]=${hashrate[1]//.*/]}
			$off; echo -n "${hashrate[0]} ${hashrate[1]} "
			[[ ${hashrate[2]} != 'n/a' ]] && hashrate[2]="${hashrate[2]} H/s"
			[[ ${hashrate[3]} != 'n/a' ]] && hashrate[3]="${hashrate[3]} H/s"
			[[ ${hashrate[4]} != 'n/a' ]] && hashrate[4]="${hashrate[4]} H/s"
			printf "\e[0m[\e[0;93m%s\e[0m%s\e[0;94m%s\e[0m%s\e[0;95m%s\e[0m] " "10s" "/" "60s" "/" "15m"
			$iyellow; echo -n "[${hashrate[2]}] "
			$iblue; echo -n "[${hashrate[3]}] "
			$ipurple; echo -n "[${hashrate[4]}]"
		fi
		echo
	}
	status_Template
}
