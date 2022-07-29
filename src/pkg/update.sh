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

# check for package version updates
# this function is used by [monero-bash update]
# but the functions below it are used more
# widely by the install/upgrade process.
pkg::update() {
	# VERBOSE MODE
	if [[ $OPTION_VERBOSE = true ]]; then
		STD_LOG_DEBUG=true
	fi

	log::debug "starting"

	# CREATE TMP FILES AND LOCK
	trap 'pkg::tmp::remove; lock::free monero_bash_update; exit 1' EXIT
	if lock::alloc "monero_bash_update"; then
		log::debug "created lock: ${STD_LOCK_FILE[monero_bash_update]}"
	else
		print::error "Could not get update lock!"
		print::exit  "Is there another [monero-bash] update running?"
	fi
	pkg::tmp::info update

	# VARIABLE
	map VER
	[[ $JOB ]] || map JOB
	local UPDATE_FOUND j
	declare -a SCRATCH UPDATE_LIST

	# TITLE
	print::pkg::update

	# START METADATA THREADS AND CREATE UPDATE_LIST
	struct::pkg bash
	UPDATE_LIST=(${PKG[short]})
	pkg::update::multi & JOB[${PKG[short]}_update]=$!
	if [[ $MONERO_VER ]]; then
		struct::pkg monero
		UPDATE_LIST=($UPDATE_LIST ${PKG[short]})
		pkg::update::multi & JOB[${PKG[short]}_update]=$!
	fi
	if [[ $P2POOL_VER ]]; then
		struct::pkg p2pool
		UPDATE_LIST=($UPDATE_LIST ${PKG[short]})
		pkg::update::multi & JOB[${PKG[short]}_update]=$!
	fi
	if [[ $XMRIG_VER ]]; then
		struct::pkg xmrig
		UPDATE_LIST=($UPDATE_LIST ${PKG[short]})
		pkg::update::multi & JOB[${PKG[short]}_update]=$!
	fi

	# WAIT FOR THREADS
	log::debug "waiting for metadata threads to complete"
	wait -f ${JOB[@]} || :

	# CHECK FAIL FILES
	log::debug "checking for failure files"
	for i in ${UPDATE_LIST[@]}; do
		struct::pkg $i
		if [[ -e "${TMP_INFO[main]}/FAIL_UPDATE_${PKG[var]}" ]]; then
			print::error "Update failure - ${PKG[pretty]} metadata fetch failed"
			local UPDATE_FAILED=true
		fi
	done
	if [[ $UPDATE_FAILED = true ]]; then
		echo
		print::error "Update failure for ${PKG[pretty]} | GitHub API connection failure"
		print::exit "Are you using a VPN/TOR? GitHub API will often rate-limit them."
	fi
	log::debug "no failure files found"


	# FILTER RESULT AND PRINT
	# always for [monero-bash]
	struct::pkg bash
	pkg::update::ver
	pkg::update::result
	if [[ $MONERO_VER ]]; then
		struct::pkg monero
		pkg::update::ver
		pkg::update::result
	fi
	if [[ $P2POOL_VER ]]; then
		struct::pkg p2pool
		pkg::update::ver
		pkg::update::result
	fi
	if [[ $XMRIG_VER ]]; then
		struct::pkg xmrig
		pkg::update::ver
		pkg::update::result
	fi

	# END
	if [[ $UPDATE_FOUND ]]; then
		echo
		printf "${BWHITE}%s${BRED}%s${BWHITE}%s${OFF}\n" \
			"Updates found, type: " \
			"[monero-bash upgrade] " \
			"to upgrade all packages"
	else
		print::pkg::updated
	fi

	log::debug "update() done"
	exit 0
}

# a template for multi-threaded updates
# uses struct::pkg to determine package
pkg::update::multi() {
	log::debug "starting metadata thread for: ${PKG[pretty]}"

	# attempt metadata download
	if $DOWNLOAD_OUT "${TMP_INFO[${PKG[short]}]}" "${PKG[link_api]}"; then
		log::debug "${PKG[pretty]} | metadata download OK"
		log::debug "downloaded ${PKG[link_api]} into ${TMP_INFO[${PKG[short]}]}"
	else
		log::debug "${PKG[pretty]} update FAIL"
		touch "${TMP_INFO[main]}/FAIL_UPDATE_${PKG[var]}" &>/dev/null || exit 1
	fi
}

# a template for filtering for the $VER from
# the info file created by pkg::update::multi()
pkg::update::ver() {
	log::debug "starting: ${PKG[pretty]}"
	# filter output
	VER[${PKG[short]}]="$(grep -m 1 "\"tag_name\":" "${TMP_INFO[${PKG[short]}]}")"
	log::debug "${PKG[pretty]} | initial \"tag_name\" filter | ${VER[${PKG[short]}]}"

	VER[${PKG[short]}]="${VER[${PKG[short]}]//*: }"
	VER[${PKG[short]}]="${VER[${PKG[short]}]//\"}"
	VER[${PKG[short]}]="${VER[${PKG[short]}]//,}"

	# sanity check for "v*"
	if [[ ${VER[${PKG[short]}]} != v* ]]; then
		log::debug "${PKG[pretty]} weird version found | ${VER[${PKG[short]}]}"
		echo
		print::exit "Upgrade failure | ${PKG[pretty]} version fetch error"
	fi

	log::debug "${PKG[pretty]} version filtered: ${VER[${PKG[short]}]}"
}

pkg::update::result() {
	# case formatting of package name
	local UPDATE_NAME
	case "${PKG[short]}" in
		*bash*) UPDATE_NAME="monero-bash | ";;
		monero) UPDATE_NAME="Monero      | ";;
		*p2p*)  UPDATE_NAME="P2Pool      | ";;
		*xmr*)  UPDATE_NAME="XMRig       | ";;
	esac

	# print result and update state
	if [[ ${PKG[current_version]} = "${VER[${PKG[short]}]}" ]]; then
		log::debug "fetched version matches state, printing BGREEN"
		printf "${BWHITE}%s${BGREEN}%s\n" \
			"$UPDATE_NAME" "${PKG[current_version]}"
	else
		log::debug "fetched version different from state, updating state and printing BRED"
		sed -i "s/${PKG[var]}_OLD=.*/${PKG[var]}_OLD=true/" "$STATE"
		UPDATE_FOUND=true
		printf "${BWHITE}%s${BRED}%s${BWHITE}%s${BGREEN}%s\n" \
			"$UPDATE_NAME" "${PKG[current_version]} " "-> " "${VER[${PKG[short]}]}"
	fi
	return 0
}
