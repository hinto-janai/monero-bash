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

# create the package list for
# reading the changelogs
print::changes::list() {
	log::debug "$1 | starting"

	local i CHANGE_LIST

	[[ $OPTION_BASH = true ]]   && CHANGE_LIST="monero-bash"
	[[ $OPTION_MONERO = true ]] && CHANGE_LIST="${CHANGE_LIST} monero"
	[[ $OPTION_P2POOL = true ]] && CHANGE_LIST="${CHANGE_LIST} p2pool"
	[[ $OPTION_XMRIG = true ]]  && CHANGE_LIST="${CHANGE_LIST} xmrig"

	# CHECK FOR FILE
	for i in $CHANGE_LIST; do
		if [[ -e "$CHANGES/$i" ]]; then
			log::debug "$CHANGES/$i found"
		else
			print::exit "$CHANGES/$i was not found!"
		fi
	done

	# PRINT VS LESS
	for i in $CHANGE_LIST; do
		if [[ $OPTION_PRINT = true ]]; then
			log::debug "$i | printing changelog"
			print::changes "$i"
		else
			log::debug "$i | piping to: less -R -N"
			print::changes "$i" | less -R -N
		fi
	done
}

# Parse a markdown file and
# create syntax highlighting.
print::changes() {
	# TURN OFF GLOBBING
	set -f

	local LINE WORD IFS=$'\n' i w CODE TITLE s FIRST SET_BOLD
	mapfile LINE < "$CHANGES/$1"
	FIRST=true

	# PARSE PER LINE
	for i in ${LINE[@]}; do
		i="${i//$'\r'}"
		unset -v WORD
		s=''
		IFS=' '
		WORD=($i)

		# PARSE PER WORD
		for w in ${WORD[@]}; do

		# PER LINE
		case "$i" in
			# TITLES
			\#*)
				if [[ ${w//[[:blank:]]} = \#* ]]; then
					if [[ $TITLE = true ]]; then
						printf "${BCYAN}%s" "$w "
					else
						if [[ $FIRST = true ]]; then
							printf "${BCYAN}%s" "$w "
							FIRST=
						else
							printf "\n${BCYAN}%s" "$w "
						fi
					fi
					TITLE=true
					continue
				fi
				;;
			# CODE BLOCKS
			*\`\`\`*)
				if [[ $CODE = true ]]; then
					CODE=
					printf "${OFF}"
					break
				else
					CODE=true
					break
				fi
				;;
			# EVERYTHING ELSE
			*)
				if [[ $CODE = true ]]; then
					printf "${BYELLOW}%s" "    $i"
					break
				elif [[ $TITLE = true ]]; then
					printf "${OFF}"
					TITLE=
				fi
				;;
		esac

		# PER WORD
		case "${w//[[:blank:]]}" in
			# LISTS
			\*)
				if [[ ${i//[[:blank:]]} = \** ]]; then
					printf "${BWHITE}%s${OFF}" "${i//\**}  •"
				else
					printf "${OFF}%s" "${s}${w}"
				fi
				;;
			-)
				if [[ ${i//[[:blank:]]} = -* ]]; then
					printf "${BWHITE}%s${OFF}" "${i//\-*}  -"
				else
					printf "${OFF}%s" "${s}${w}"
				fi
				;;

			# BOLD/ITALIC
			\**\*)
				printf "${BWHITE}%s${OFF}" "${s}${w//\*}";;
			\**)
				printf "${BWHITE}%s" "${s}${w//\*}"
				SET_BOLD=true
				;;
			*\`*\*)
				w="${w//\`}"
				printf "${BRED}%s${OFF}" "${s}${w//\*}"
				SET_BOLD=
				;;
			*\*)
				w="${w//\`}"
				printf "${BWHITE}%s${OFF}" "${s}${w//\*}"
				SET_BOLD=
				;;

			# LINKS
			\[*\]\(*\)) printf "${BPURPLE}%s${OFF}" "${s}${w}";;
			[*) printf "${BPURPLE}%s" "${s}${w}";;
			*]\(*\)) printf "%s${OFF}" "${s}${w}";;

			# SMALL CODE
			\`*\`)
				w="${w//\*}"
				if [[ $SET_BOLD = true ]]; then
					printf "${BRED} %s${BWHITE}" "${w//\`}"
				else
					printf "${BRED} %s${OFF}" "${w//\`}"
				fi
				;;
			\`*)
				w="${w//\*}"
				if [[ $SET_BOLD = true ]]; then
					printf "${BRED} %s${BWHITE}" "${w//\`}"
				else
					printf "${BRED} %s${OFF}" "${w//\`}"
				fi
				;;
			*\`)
				w="${w//\*}"
				if [[ $SET_BOLD = true ]]; then
					printf "${BRED} %s${BWHITE}" "${w//\`}"
				else
					printf "${BRED} %s${OFF}" "${w//\`}"
				fi
				;;

			# EVERYTHING ELSE
			*)	printf "%s" "${s}${w}"
		esac
		s=' '
		done
		printf "\n"
	done
}
