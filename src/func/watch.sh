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


# watch functions - for watching output of the systemd services created
# by monero-bash, e.g. "monero-bash-xmrig.service"
#
# This used to use `watch` from core-utils but
# since it didn't support more than 8-bit color
# its output was pretty ugly. These functions
# simulate `watch` by:
#     1. buffering the output into a variable
#     2. clearing the screen
#     3. printing variable
#     4. sleeping
#     5. repeat

watch_Template()
{
	if [[ $XMRIG_VER ]]; then
		prompt_Sudo; error_Sudo
	fi
	# tput lines = available lines detected terminal
	# divided by 2 to account for line wraps.
	# 1 line that line wraps still counts as 1 line,
	# this makes it so bottom messages won't be seen.
	unset -v WATCH_LINES DOT_COLOR STATS IFS VAR_1 VAR_2
	local WATCH_LINES DOT_COLOR STATS IFS=$'\n' VAR_1 VAR_2
	[[ $STATUS_LIST ]] || watch_Create_List
	[[ $CURRENT ]] || declare -g CURRENT=1
	[[ $WATCH_LINES ]] || WATCH_LINES=$(tput lines)
	trap 'clear; printf "\e[1;97m%s\e[1;95m%s\e[1;97m%s\n" "[Exiting: " "${SERVICE}" "]"; exit 0' EXIT

	# need sudo for xmrig journals
	if [[ $SERVICE = "monero-bash-xmrig.service" ]]; then
		while :; do
			sudo -v
			STATS=$(sudo journalctl --no-pager -n $WATCH_LINES -u $SERVICE --output cat) SYSTEMD_STATS=$(sudo systemctl status $SERVICE)
			STAT_UPTIME=$(watch_Uptime) STAT_DATE=$(date) STAT_AMOUNT=$(watch_Amount)
			case "$SYSTEMD_STATS" in
				*"Active: active"*) DOT_COLOR="\e[1;92mONLINE: ${NAME_PRETTY} $NAME_VER";;
				*"Active: inactive"*) [[ $PROC_UPTIME ]] && DOT_COLOR="\e[1;92mONLINE \e[1;93m(not using systemd): ${NAME_PRETTY} $NAME_VER" || DOT_COLOR="\e[1;91mOFFLINE: ${NAME_PRETTY} $NAME_VER";;
				*"Active: failed"*) [[ $PROC_UPTIME ]] && DOT_COLOR="\e[1;92mONLINE \e[1;93m(not using systemd): ${NAME_PRETTY} $NAME_VER" || DOT_COLOR="\e[1;91mFAILED: ${NAME_PRETTY} $NAME_VER";;
				*) DOT_COLOR="\e[1;93m???: ${NAME_PRETTY}";;
			esac
			echo -e "$STATS"
			printf "\n\e[${WATCH_LINES};0\e[1;97m[${DOT_COLOR}\e[1;97m] [\e[1;95m%s\e[1;97m%s\e[1;94m%s\e[1;97m%s\e[0;97m%s\e[1;97m%s\e[0m " \
				"$STAT_DATE" "] [" "$STAT_UPTIME" "] [" "$STAT_AMOUNT" "]"
			# exit on any input unless [left] or [right] escape codes
			read -r -s -N 1 -t 1 VAR_1
			if [[ $VAR_1 = $'\e' ]]; then
				read -r -s -n 2 -t 0.00001 VAR_2
				case "$VAR_2" in
					'[C') watch_Next ;;
					'[D') watch_Prev ;;
					*) exit 0;;
				esac
			elif [[ $VAR_1 || $VAR_1 = $'\x0a' ]]; then
					exit 0
			fi
		done
	else
		while :; do
			[[ $XMRIG_VER ]] && sudo -v
			STATS=$(journalctl --no-pager -n $WATCH_LINES -u $SERVICE --output cat) SYSTEMD_STATS=$(systemctl status $SERVICE)
			STAT_UPTIME=$(watch_Uptime) STAT_DATE=$(date) STAT_AMOUNT=$(watch_Amount)
			case "$SYSTEMD_STATS" in
				*"Active: active"*) DOT_COLOR="\e[1;92mONLINE: ${NAME_PRETTY} $NAME_VER";;
				# if process is detected, but not with systemd (foreground)
				*"Active: inactive"*) [[ $PROC_UPTIME != '...' ]] && DOT_COLOR="\e[1;92mONLINE \e[1;93m(non-systemd): ${NAME_PRETTY} $NAME_VER" || DOT_COLOR="\e[1;91mOFFLINE: ${NAME_PRETTY} $NAME_VER";;
				*"Active: failed"*) [[ $PROC_UPTIME != '...' ]] && DOT_COLOR="\e[1;92mONLINE \e[1;93m(non-systemd): ${NAME_PRETTY} $NAME_VER" || DOT_COLOR="\e[1;91mFAILED: ${NAME_PRETTY} $NAME_VER";;
				*) DOT_COLOR="\e[1;93m???: ${NAME_PRETTY} $NAME_VER";;
			esac
			clear
			echo -e "$STATS"
			printf "\n\e[${WATCH_LINES};0\e[1;97m[${DOT_COLOR}\e[1;97m] [\e[1;95m%s\e[1;97m%s\e[1;94m%s\e[1;97m%s\e[0;97m%s\e[1;97m%s\e[0m " \
				"$STAT_DATE" "] [" "$STAT_UPTIME" "] [" "$STAT_AMOUNT" "]"
			# exit on any input unless [left] or [right] escape codes
			read -r -s -N 1 -t 1 VAR_1
			if [[ $VAR_1 = $'\e' ]]; then
				read -r -s -n 2 -t 0.00001 VAR_2
				case "$VAR_2" in
					'[C') watch_Next ;;
					'[D') watch_Prev ;;
					*) exit 0;;
				esac
			elif [[ $VAR_1 || $VAR_1 = $'\x0a' ]]; then
					exit 0
			fi
		done
	fi
}

# Watch [monero-bash status] at 1-second intervals. Thanks for the idea u/austinspringer64
# https://www.reddit.com/r/Monero/comments/wqp62v/comment/ikoijbh/?utm_source=reddit&utm_medium=web2x&context=3
watch_Status() {
	if [[ $XMRIG_VER ]]; then
		prompt_Sudo; error_Sudo
	fi
	unset -v COL STATS VAR_1 VAR_2
	[[ $STATUS_LIST ]] || watch_Create_List
	[[ $CURRENT ]] || declare -g CURRENT=0
	WATCH_LINES=$(tput lines)
	if [[ $MONERO_BASH_OLD = true ]]; then
		COL="\e[1;91m"
	else
		COL="\e[1;92m"
	fi
	trap 'clear; printf "\e[1;97m%s\e[1;95m%s\e[1;97m%s\n" "[Exiting: " "monero-bash status" "]"; exit 0' EXIT
	while :; do
		[[ $XMRIG_VER ]] && sudo -v
		# use status_Watch() instead of re-invoking and
		# loading [monero-bash status] into memory every loop
		local STATS=$(status_Watch) STAT_UPTIME=$(uptime -p) STAT_DATE=$(date) STAT_AMOUNT=$(watch_Amount)
		clear
		echo -e "$STATS"
		echo nani
		printf "\e[${WATCH_LINES};0"
		printf "\e[1;97m%s${COL}%s\e[1;97m%s\e[1;95m%s\e[1;97m%s\e[1;94m%s\e[1;97m%s\e[0;97m%s\e[1;97m%s\e[0m " \
			"[" "monero-bash ${MONERO_BASH_VER}" "] [" "$STAT_DATE" "] [" "$STAT_UPTIME" "] [" "$STAT_AMOUNT" "]"
		# exit on any input unless [left] or [right] escape codes
		read -r -s -N 1 -t 1 VAR_1
		if [[ $VAR_1 = $'\e' ]]; then
			read -r -s -n 2 -t 0.00001 VAR_2
			case "$VAR_2" in
				'[C') watch_Next ;;
				'[D') watch_Prev ;;
				*) exit 0;;
			esac
		elif [[ $VAR_1 || $VAR_1 = $'\x0a' ]]; then
				exit 0
		fi
	done
}

watch_Create_List() {
# create list of installed packages to
# cycle through with [left] & [right]
	declare -a -g STATUS_LIST
	STATUS_LIST=(Status)
	[[ $MONERO_VER ]] && STATUS_LIST=(${STATUS_LIST[@]} Monero)
	[[ $P2POOL_VER ]] && STATUS_LIST=(${STATUS_LIST[@]} P2Pool)
	[[ $XMRIG_VER ]]  && STATUS_LIST=(${STATUS_LIST[@]} XMRig)
}

watch_Next() {
	# if only 1 thing in list, do nothing
	if [[ ${#STATUS_LIST[@]} = 1 ]]; then
		:
	# if the next array element exists, next
	elif [[ ${STATUS_LIST[$((CURRENT+1))]} ]]; then
		((CURRENT++))
		watch_${STATUS_LIST[$CURRENT]}
	# else return to 0 (status)
	else
		CURRENT=0
		watch_Status
	fi
}

watch_Prev() {
	# if only 1 thing in list, do nothing
	if [[ ${#STATUS_LIST[@]} = 1 ]]; then
		:
	# if current is 0, go to -1
	elif [[ $CURRENT = 0 ]]; then
		CURRENT=$((${#STATUS_LIST[@]}-1))
		watch_${STATUS_LIST[-1]}
	# if it's status, watch status
	elif [[ ${STATUS_LIST[$((CURRENT-1))]} = status ]]; then
		CURRENT=0
		watch_Status
	# else, goto prev
	else
		CURRENT=$((CURRENT-1))
		watch_${STATUS_LIST[$CURRENT]}
	fi
}

# calculate and return process uptime
watch_Uptime() {
	if PROC_UPTIME=$(pgrep $DIRECTORY/$PROCESS -f); then
		PROC_UPTIME=$(ps -o "%t" -p $PROC_UPTIME)
		printf "%s" "${PROC_UPTIME//[!0-9:-]}"
	else
		PROC_UPTIME='...'
		printf "%s" "$PROC_UPTIME"
	fi
}

# calculate list for 1/4
watch_Amount() {
	# process amount = 1
	if [[ ${#STATUS_LIST[@]} = 1 ]]; then
		printf "%s" "1/1"
	else
		# process amount -gt 1
		printf "%s" "$((CURRENT+1))/${#STATUS_LIST[@]}"
	fi
}
watch_Monero()
{
	define_Monero
	watch_Template
}

watch_XMRig()
{
	define_XMRig
	watch_Template
}

watch_P2Pool()
{
	define_P2Pool
	watch_Template
}
