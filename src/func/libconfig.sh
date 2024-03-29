# libconfig.sh
#
# Copyright (c) 2022 hinto.janaiyo <https://github.com/hinto-janai>
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

#git <libconfig/libconfig.sh/99dc038>

config::grep() {
	# init local variables
	local i LIBCONFIG_FILE LIBCONFIG_ARG LIBCONFIG_OUTPUT_TYPE LIBCONFIG_OUTPUT_MOD IFS=$'\n' || return 1
	declare -a LIBCONFIG_ARRAY LIBCONFIG_OUTPUT || return 1

	# check for correct arguments
	[[ $# -lt 3 ]] && return 2

	# parse args
	case $1 in
		--prefix=*|--map=*)
			# check for even arguments
			LIBCONFIG_ARG=$(($# % 2))
			[[ $LIBCONFIG_ARG = 0 ]] || return 3
			LIBCONFIG_OUTPUT_TYPE="$1"
			LIBCONFIG_FILE="$2"
			shift 2
			;;
		*)
			# check for odd arguments
			LIBCONFIG_ARG=$(($# % 2))
			[[ $LIBCONFIG_ARG = 1 ]] || return 3
			LIBCONFIG_FILE="$1"
			shift 1
			;;
	esac

	# check if config is a file
	[[ -f $LIBCONFIG_FILE ]] || return 4
	# check for read permission
	[[ -r $LIBCONFIG_FILE ]] || return 5

	# create line array of file
	mapfile LIBCONFIG_ARRAY < "$LIBCONFIG_FILE" || return 6
	# strip quotes
	LIBCONFIG_ARRAY=(${LIBCONFIG_ARRAY[@]//\"})
	LIBCONFIG_ARRAY=(${LIBCONFIG_ARRAY[@]//\'})

	# determine output type
	case $LIBCONFIG_OUTPUT_TYPE in
		--map=*)    LIBCONFIG_OUTPUT_MOD="${LIBCONFIG_OUTPUT_TYPE/*=}"; LIBCONFIG_OUTPUT_TYPE=map;;
		--prefix=*) LIBCONFIG_OUTPUT_MOD="${LIBCONFIG_OUTPUT_TYPE/*=}"; LIBCONFIG_OUTPUT_TYPE=prefix;;
	esac

	# loop over arguments
	until [[ $# = 0 ]]; do
		# loop over file per argument given
		for i in ${LIBCONFIG_ARRAY[@]}; do
			# continue if basic pattern does not match
			[[ $i = ${2}* ]] || continue
			# else case the data type and check for match
			case $1 in
				ip) [[ $i =~ ^${2}=localhost$ || $i =~ ^${2}=[[:alnum:].]+'.'[[:alnum:]]+$ ]] && LIBCONFIG_OUTPUT+=("${2//-/_}=${i/*=/}");;
				port) [[ $i =~ ^${2}=localhost':'[0-9]+$ || $i =~ ^${2}=[[:alnum:].]+'.'[[:alnum:]]+':'[0-9]+$ ]] && LIBCONFIG_OUTPUT+=("${2//-/_}=${i/*=/}");;
				int) [[ $i =~ ^${2}=[0-9]+$ || $i =~ ^${2}=-[0-9]+$ ]] && LIBCONFIG_OUTPUT+=("${2//-/_}=${i/*=/}");;
				pos) [[ $i =~ ^${2}=[0-9]+$ ]] && LIBCONFIG_OUTPUT+=("${2//-/_}=${i/*=/}");;
				neg) [[ $i =~ ^${2}=-[0-9]+$ ]] && LIBCONFIG_OUTPUT+=("${2//-/_}=${i/*=/}");;
				bool) [[ $i =~ ^${2}=true$ || $i =~ ^${2}=false$ ]] && LIBCONFIG_OUTPUT+=("${2//-/_}=${i/*=/}");;
				char) [[ $i =~ ^${2}=[[:alnum:]._-]+$ ]] && LIBCONFIG_OUTPUT+=("${2//-/_}=${i/*=/}");;
				path) [[ $i =~ ^${2}=[[:alnum:]./_-]+$ ]] && LIBCONFIG_OUTPUT+=("${2//-/_}=${i/*=/}");;
				proto) [[ $i =~ ^${2}=[[:alpha:]]+://[[:alnum:]./?=_%:-]+$ || $i =~ ^${2}=[[:alpha:]]+://[[:alnum:]./?=_%:-]+':'[0-9]+$ ]] && LIBCONFIG_OUTPUT+=("${2//-/_}=${i/*=/}");;
				web) [[ $i =~ ^${2}='http://'[[:alnum:]./?=_%:-]+$ || $i =~ ^${2}='https://'[[:alnum:]./?=_%:-]+$ || $i =~ ^${2}='www.'[[:alnum:]./?=_%:-]+$ ]] && LIBCONFIG_OUTPUT+=("${2//-/_}=${i/*=/}");;
				any)
					if [[ $i =~ ^${2}=.*$ ]]; then
						[[ ${i/${2}=} ]] && LIBCONFIG_OUTPUT+=("${2//-/_}=${i/*=/}")
					fi;;
				\[*\]*|\(*\)*) LIBCONFIG_RANGE="$1" && [[ $i =~ ^${2}=${LIBCONFIG_RANGE}$ ]] && LIBCONFIG_OUTPUT+=("${2//-/_}=${i/*=/}");;
				*) return 7;;
			esac
		done
		shift 2
	done

	# return error on nothing found
	[[ $LIBCONFIG_OUTPUT ]] || return 8

	# determine output type
	case $LIBCONFIG_OUTPUT_TYPE in
		prefix) printf "${LIBCONFIG_OUTPUT_MOD}%s\n" "${LIBCONFIG_OUTPUT[@]}";;
		map)    printf "${LIBCONFIG_OUTPUT_MOD}[%s\n" "${LIBCONFIG_OUTPUT[@]/=/\]=}";;
		*)      printf "%s\n" "${LIBCONFIG_OUTPUT[@]}";;
	esac
}

config::merge() {
	# init local variables.
	local i IFS=$'\n' || return 1
	local -a LIBCONFIG_OLD LIBCONFIG_CMD || return 2

	# check amount of arguments
	case $# in
		2) :;;
		*) return 3
	esac

	# check if file
	[[ -f $1 ]] || return 3
	[[ -f $2 ]] || return 4

	# check for read permission
	[[ -r $1 ]] || return 5
	[[ -r $2 ]] || return 6

	# get old values from (a) in memory
	LIBCONFIG_OLD=($(sed "/^#.*/d; /^$/d; s@/@\\\/@g; s/'//g; s/\"//g; s/\[/\\\[/g; s/\]/\\\]/g" "$1" | grep "^.*=.*$")) || return 7

	# create the find/replace argument in one
	# line instead of invoking sed every loop
	# account for commented out values as well.
	for i in ${LIBCONFIG_OLD[@]}; do
		if [[ $i = *' '* ]]; then
			LIBCONFIG_CMD+=("-e s/^${i/=*}.*$/${i/=*/=}\"${i/*=}\"/g" "-e s/^#\+${i/=*}.*$/${i/=*/=}\"${i/*=}\"/g")
		else
			LIBCONFIG_CMD+=("-e s/^${i/=*/=}.*$/${i}/g" "-e s/^#\+${i/=*/=}.*$/${i}/g")
		fi
	done

	# invoke sed once, with the long argument we just created
	LIBCONFIG_CMD=(sed "${LIBCONFIG_CMD[@]}" "$2")
	"${LIBCONFIG_CMD[@]}"
}
