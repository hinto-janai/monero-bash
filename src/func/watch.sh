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
	# tput lines = available lines detected terminal
	# divided by 2 to account for line wraps.
	# 1 line that line wraps still counts as 1 line,
	# this makes it so bottom messages won't be seen.
	unset -v HALF_LINES STATS
	local DOT_COLOR HALF_LINES STATS IFS=$'\n'
	HALF_LINES=$(($(tput lines) / 2))
	trap 'clear; printf "\e[1;97m%s\e[1;95m%s\e[1;97m%s\n" "[Exiting: " "${SERVICE}" "]"' EXIT

	# need sudo for xmrig journals
	if [[ $SERVICE = "monero-bash-xmrig.service" ]]; then
		while :; do
			STATS=$(sudo journalctl -u $SERVICE --output cat | tail -n $HALF_LINES)
			SYSTEMD_STATS=$(sudo systemctl status $SERVICE)
			case "$SYSTEMD_STATS" in
				*"Active: active"*) DOT_COLOR="\e[1;92mONLINE: ${SERVICE}";;
				*"Active: inactive"*) DOT_COLOR="\e[1;91mOFFLINE: ${SERVICE}";;
				*"Active: failed"*) DOT_COLOR="\e[1;91mFAILED: ${SERVICE}";;
				*) DOT_COLOR="\e[1;93m???: ${SERVICE}";;
			esac
			clear
			printf "\e[1;97m[${DOT_COLOR}\e[1;97m] [\e[0;97m%s\e[1;97m]\e[0m\n\n" "$(date)"
			echo -e "$STATS"
			read -s -t 1 && read -s -t 1
		done
	else
		while :; do
			STATS=$(journalctl -u $SERVICE --output cat | tail -n $HALF_LINES)
			SYSTEMD_STATS=$(systemctl status $SERVICE)
			case "$SYSTEMD_STATS" in
				*"Active: active"*) DOT_COLOR="\e[1;92mONLINE: ${SERVICE}";;
				*"Active: inactive"*) DOT_COLOR="\e[1;91mOFFLINE: ${SERVICE}";;
				*"Active: failed"*) DOT_COLOR="\e[1;91mFAILED: ${SERVICE}";;
				*) DOT_COLOR="\e[1;93m???: ${SERVICE}";;
			esac
			clear
			printf "\e[1;97m[${DOT_COLOR}\e[1;97m] [\e[0;97m%s\e[1;97m]\e[0m\n\n" "$(date)"
			echo -e "$STATS"
			read -s -t 1 && read -s -t 1
		done
	fi
}

# Watch [monero-bash status] at 1-second intervals. Thanks for the idea u/austinspringer64
# https://www.reddit.com/r/Monero/comments/wqp62v/comment/ikoijbh/?utm_source=reddit&utm_medium=web2x&context=3
watch_Status() {
	trap 'clear; printf "\e[1;97m%s\e[1;95m%s\e[1;97m%s\n" "[Exiting: " "monero-bash status" "]"' EXIT
	while :; do
		# use status_All() instead of re-invoking and
		# loading [monero-bash status] into memory every loop
		local STATS=$(status_Watch)
		clear
		printf "\e[1;97m%s\e[1;93m%s\e[1;97m%s\e[1;94m%s\e[0;97m%s\e[1;97m%s\e[1;35m%s\e[0;97m%s\e[1;97m%s\e[0m\n\n" \
			"[Watching: " "monero-bash status" "] [" "System: " "$(uptime -p)" "] [" "Time: " "$(date)" "]"
		echo -e "$STATS"
		read -s -t 1 && read -s -t 1
	done
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
