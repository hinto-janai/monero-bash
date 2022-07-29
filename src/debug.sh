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

# directly execute a monero-bash function
# this skips safety checks and option parsing
# use carefully!
DEBUG() {
	log::debug "STARTING DEBUG MODE"
	local DEBUG_FUNCTION || return 1

	printf "${BRED}%s\n${BWHITE}%s\n${BWHITE}%s\n${BWHITE}%s\n${BWHITE}%s\n" \
		"   ===> MONERO-BASH DEBUG MODE <===   " \
		"@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" \
		"@ you are executing a monero-bash    @" \
		"@ function directly, use carefully!  @" \
		"@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"

	# if #2 exists, re-confirm
	if [[ $2 ]]; then
		printf "${BGREEN}%s${BWHITE}%s\n${OFF}%s" \
			"function(): " \
			"$2" \
			"Execute this function? (y/N) "
		if ask::no; then
			printf "%s\n" "Exiting..."
			exit 1
		fi
		DEBUG_FUNCTION="$2" || return 2
	else
		# else ask for function name
		printf "${BGREEN}%s${OFF}" "function(): "
		read -r DEBUG_FUNCTION || return 3
	fi

	# check if function exists
	if ! declare -fp "$DEBUG_FUNCTION" &>/dev/null; then
		log::fail "$DEBUG_FUNCTION not found"
		exit 1
	fi

	# execute function
	printf "%s\n" "EXECUTING FUNCTION: $DEBUG_FUNCTION"
	$DEBUG_FUNCTION
	exit
}
