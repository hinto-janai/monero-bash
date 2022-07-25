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
pkg::update() {
	# VERBOSE MODE
	if [[ $OPTION_VERBOSE = true ]]; then
		STD_LOG_DEBUG=true
	fi

	log::debug "starting ${FUNCNAME}()"

	# CREATE TMP FILES AND LOCK
	trap '{ pkg::tmp::remove; lock::free monero_bash_update; } &' EXIT
	if ! lock::alloc "monero_bash_update"; then
		print::error "Could not get update lock!"
		print::exit  "Is there another [monero-bash] update running?"
	fi
	pkg::tmp::info update

	# VARIABLE
	map VER
	local UPDATE_FOUND
	declare -a SCRATCH

	# TITLE
	print::update

	# START METADATA THREADS
	struct::pkg bash
	pkg::update::multi &
	if [[ $MONERO_VER ]]; then
		struct::pkg monero
		pkg::update::multi &
	fi
	if [[ $P2POOL_VER ]]; then
		struct::pkg p2pool
		pkg::update::multi &
	fi
	if [[ $XMRIG_VER ]]; then
		struct::pkg xmrig
		pkg::update::multi &
	fi

	# WAIT FOR THREADS
	log::debug "waiting for metadata threads to complete"
	if ! wait -n; then
		print::exit "Update failure - update threads failed"
	fi

	# FILTER RESULT AND PRINT
	# always for [monero-bash]
	struct::pkg bash
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
		print::updated
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
		log::debug "downloaded ${PKG[link_api]} into ${TMP_INFO[${PKG[short]}]}"
		return 0
	else
		print::error "Update failure for ${PKG[pretty]} | GitHub API connection failure"
		print::error "Are you using a VPN/TOR? GitHub API will often rate-limit them."
		return 1
	fi
}

# a template for filtering for the $VER from
# the info file created by pkg::update::multi()
pkg::update::ver() {
	# filter output
	VER[${PKG[short]}]="$(grep -m 1 "tag_name" "${TMP_INFO[${PKG[short]}]}")"
	VER[${PKG[short]}]="${VER[${PKG[short]}//*: }"
	VER[${PKG[short]}]="${VER[${PKG[short]}//\"}"
	VER[${PKG[short]}]="${VER[${PKG[short]}//,}"
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
		printf "${BWHITE}%s${BGREEN}%s\n" \
			"$UPDATE_NAME" "${PKG[current_version]}"
	else
		sed -i "s/${PKG[var]}_OLD=.*/${PKG[var]}_OLD=true/" "$STATE"
		UPDATE_FOUND=true
		printf "${BWHITE}%s${BRED}%s${BWHITE}%s${BGREEN}%s\n" \
			"$UPDATE_NAME" "${PKG[current_version]} " "-> " "${VER[${PKG[short]}]}"
	fi
	return 0
}
