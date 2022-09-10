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

# panic()
# -------
# a panic function for when things get bad
# and we really should just exit or loop forever.
# taken from <https://github.com/hinto-janaiyo/stdlib>
# modified to add cowsay :)

panic() {
	# get error info
	local STD_PANIC_CODE="$?" STD_PANIC_FUNC=("${BASH_LINENO[@]}") STD_PANIC_CMD_NUM=${BASH_LINENO[0]}|| exit 98
	# ultra paranoid safety measures (unset bash builtins)
	POSIXLY_CORRECT= || exit 11
	\unset -f trap set return exit printf echo local unalias unset builtin kill || exit 22
	\unalias -a || exit 33
	unset POSIXLY_CORRECT || exit 44
	unset : || exit 55
	printf "\e[7m\e[0;m%s\e[0m\n" "@@@@@@@@ [$0] panic at [${STD_PANIC_CMD_NUM}] @@@@@@@@"
	# get command based off line number from $STD_PANIC_CMD_NUM
	local STD_PANIC_CMD
	mapfile -s $((STD_PANIC_CMD_NUM-1)) -n 1 STD_PANIC_CMD < $0
	# print info
	printf "\e[1;91m%s\e[0m%s\n" "[code] " "$STD_PANIC_CODE"
	printf "\e[1;94m%s\e[0m%s\n" "[ wd ] " "$PWD"
	# print function stack
	local f
	local i=1
	STD_PANIC_FUNC=("${STD_PANIC_FUNC[@]:1}")
	for f in ${STD_PANIC_FUNC[@]}; do
		[[ $f = 0 ]] && break
		printf "\e[1;92m%s\e[0m%s\n" "[func] " "${f}: ${FUNCNAME[${i}]}()"
		((i++))
	done
	# put trace lines into array, error line in middle, 9 lines total
	local STD_PANIC_LINE_ARRAY
	local STD_ORIGINAL_LINE="$STD_PANIC_CMD_NUM"
	# prevent negative starting line
	if [[ $STD_PANIC_CMD_NUM -lt 5 ]]; then
		local STD_PANIC_CMD_NUM=1
		mapfile -n 9 STD_PANIC_LINE_ARRAY < $0
	else
		local STD_PANIC_CMD_NUM=$((STD_PANIC_CMD_NUM-4))
		mapfile -s $((STD_PANIC_CMD_NUM-1)) -n 9 STD_PANIC_LINE_ARRAY < $0
	fi
	# print lines with numbers (with manual spacing)
	# the array elements already have newlines,
	# so none are added with printf.
	for i in {0..8}; do
		# if no lines left, break
		[[ ${STD_PANIC_LINE_ARRAY[$i]} ]] || break
		# if error line, print bold white
		if [[ $STD_PANIC_CMD_NUM = "$STD_ORIGINAL_LINE" ]]; then
			case ${#STD_PANIC_CMD_NUM} in
				1) printf "\e[1;97m%s" "     $STD_PANIC_CMD_NUM ${STD_PANIC_LINE_ARRAY[${i}]}" ;;
				2) printf "\e[1;97m%s" "    $STD_PANIC_CMD_NUM ${STD_PANIC_LINE_ARRAY[${i}]}" ;;
				3) printf "\e[1;97m%s" "   $STD_PANIC_CMD_NUM ${STD_PANIC_LINE_ARRAY[${i}]}" ;;
				4) printf "\e[1;97m%s" "  $STD_PANIC_CMD_NUM ${STD_PANIC_LINE_ARRAY[${i}]}" ;;
				5) printf "\e[1;97m%s" " $STD_PANIC_CMD_NUM ${STD_PANIC_LINE_ARRAY[${i}]}" ;;
				*) printf "\e[1;97m%s" "$STD_PANIC_CMD_NUM ${STD_PANIC_LINE_ARRAY[${i}]}" ;;
			esac
		# else print grey
		else
			case ${#STD_PANIC_CMD_NUM} in
				1) printf "\e[1;90m%s" "     $STD_PANIC_CMD_NUM ${STD_PANIC_LINE_ARRAY[${i}]}" ;;
				2) printf "\e[1;90m%s" "    $STD_PANIC_CMD_NUM ${STD_PANIC_LINE_ARRAY[${i}]}" ;;
				3) printf "\e[1;90m%s" "   $STD_PANIC_CMD_NUM ${STD_PANIC_LINE_ARRAY[${i}]}" ;;
				4) printf "\e[1;90m%s" "  $STD_PANIC_CMD_NUM ${STD_PANIC_LINE_ARRAY[${i}]}" ;;
				5) printf "\e[1;90m%s" " $STD_PANIC_CMD_NUM ${STD_PANIC_LINE_ARRAY[${i}]}" ;;
				*) printf "\e[1;90m%s" "$STD_PANIC_CMD_NUM ${STD_PANIC_LINE_ARRAY[${i}]}" ;;
			esac
		fi
		((STD_PANIC_CMD_NUM++))
	done
	# cowsay
	printf "${OFF}%s\n" \
	" ________________________________________________________   " \
	"/ You've encountered a fatal error in [monero-bash]!     \\ " \
	"| It would be very helpful if you reported this bug with |  " \
	"| the information above to the GitHub issues page at:    |  "
	printf "%s${BYELLOW}%s${OFF}%s\n" \
	"\\ " "<https://github.com/hinto-janaiyo/monero-bash/issues>" "  / "
	printf "%s\n" \
	" --------------------------------------------------------   " \
	"        \   ^__^                           " \
	"         \  (oo)\_______                   " \
	"            (__)\       )\\/\\             " \
	"                ||----w |                  " \
	"                ||     ||                  "
	[[ $1 =~ ^[0-9]+$ ]] && exit $1 || exit 99
	# endless loop
	while :; do read -s -r; done
	# just in case, kill and exit
	printf "\e[0;m%s\n" "@ loop fail, killing \$$ @"
	builtin kill -s KILL 0
}
