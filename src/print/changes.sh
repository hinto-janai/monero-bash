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

# Parse a markdown file and
# create syntax highlighting.
print::changes() {
	log::debug "starting ${FUNCNAME}() for: $1"

	# TURN OFF GLOBBING
	set -f

	local LINE WORD IFS=$'\n' i w SET_CODE_BLOCK
	mapfile LINE < "$CHANGES/$1"

	# PARSE PER LINE
	for i in ${LINE[@]}; do
		i="${i//$'\r'}"
		unset -v WORD
		IFS=' '
		WORD=($i)

		# PARSE PER WORD
		for w in ${WORD[@]}; do
		case "$w" in

		# TITLES
		\#*) printf "${BCYAN}%s" "$w";;
		\*) printf "${BWHITE}•${OFF}%s" "${w/\*}";;
		-) printf "${IWHITE}    •${OFF}%s" "${w/-}";;

		# BOLD/ITALIC
		\*\**) printf "${BWHITE}%s" " ${w//\*\*}";;
		*\*\*) printf "%s${OFF}" " ${w//\*\*}";;

		# LINKS
		\[*\]\(*\)) printf "${BPURPLE}%s${OFF}" " $w";;
		[*) printf "${BPURPLE}%s" " $w";;
		*]\(*\)) printf "%s${OFF}" " $w";;

		# CODE BLOCKS
		*\`\`\`*)
			if [[ $SET_CODE_BLOCK != true ]]; then
				SET_CODE_BLOCK=true
				printf "${BYELLOW}"
			else
				SET_CODE_BLOCK=false
				printf "${OFF}"
			fi
			;;
		\`*\`) printf " \e[1;91m%s${OFF}" "${w//\`}";;
		\`*) printf " \e[1;91m%s" "${w//\`}";;
		*\`) printf "\e[1;91m %s${OFF}" "${w//\`}";;

		# EVERYTHING ELSE
		*) printf "%s" " $w";;

		esac
		done
		printf "\n"
	done
}
