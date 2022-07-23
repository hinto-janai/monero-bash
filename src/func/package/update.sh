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
update() {
	log::debug "starting ${FUNCNAME}()"

	# CREATE TMP FILES AND LOCK
	trap 'tmp::remove; lock::free monero_bash_update' EXIT
	lock::alloc "monero_bash_update"
	tmp::info

	# VARIABLE
	local UPDATE_FOUND INFO HTML
	declare -a SCRATCH

	# TITLE
	print::update

	# ALWAYS UPDATE MONERO-BASH
	struct::pkg bash
	log::debug "starting download thread for: ${PKG[pretty]}"
	# switch to html mode if github api fails
	if ! $DOWNLOAD_CMD "${TMP_INFO[bash]}" "${PKG[link_api]}"; then
		HTML_MODE=true
		printf "${BRED}%s${OFF}%s${BYELLOW}%s${OFF}\n" \
			"GitHub API failure " \
			"| " \
			"Switching to HTML filter mode..."
		if ! $DOWNLOAD_CMD "${TMP_INFO[bash]}" "${PKG[link_html]}"; then
			print::exit "Update failure - could not connect to GitHub"
		fi
	fi
	# filter result
	if [[ $HTML_MODE = true ]]; then
		SCRATCH=($(grep -o -m 1 "/${PKG[author]}/${PKG[name]}/releases/tag/.*\"" "${TMP_INFO[bash]}"))
		INFO="${SCRATCH[0]}"
		INFO="${INFO//*tag\/}"
		INFO="${INFO//\"}"
	else
		INFO="$(grep -m1 "tag_name" "${TMP_INFO[bash]}")"
		INFO="${INFO//*: }"
		INFO="${INFO//\"}"
		INFO="${INFO//,}"
	fi
	# print result and update state
	if [[ $MONERO_BASH_VER = "${INFO}" ]]; then
		printf "${BWHITE}%s${BGREEN}%s\n" \
			"monero-bash | " "$MONERO_BASH_VER"
	else
		sed -i "s/MONERO_BASH_OLD=.*/MONERO_BASH_OLD=true/" "$STATE"
		UPDATE_FOUND=true
		printf "${BWHITE}%s${BRED}%s${BWHITE}%s${BGREEN}%s\n" \
			"monero-bash | " "$MONERO_BASH_VER " "-> " "$INFO"
	fi

	# START MULTI-THREADED DOWNLOAD ON OTHER PACKAGES
	# monero
	if [[ $MONERO_VER ]]; then
		struct::pkg monero
		log::debug "starting download thread for: ${PKG[pretty]}"
		# api/html
		if [[ $HTML_MODE = true ]]; then
			$DOWNLOAD_CMD "${TMP_INFO[monero]}" "${PKG[link_html]}" &
		else
			$DOWNLOAD_CMD "${TMP_INFO[monero]}" "${PKG[link_api]}" &
		fi
	fi
	# p2pool
	if [[ $P2POOL_VER ]]; then
		struct::pkg p2pool
		log::debug "starting download thread for: ${PKG[pretty]}"
		# api/html
		if [[ $HTML_MODE = true ]]; then
			$DOWNLOAD_CMD "${TMP_INFO[p2pool]}" "${PKG[link_html]}" &
		else
			$DOWNLOAD_CMD "${TMP_INFO[p2pool]}" "${PKG[link_api]}" &
		fi
	fi
	# xmrig
	if [[ $XMRIG_VER ]]; then
		struct::pkg xmrig
		log::debug "starting download thread for: ${PKG[pretty]}"
		# api/html
		if [[ $HTML_MODE = true ]]; then
			$DOWNLOAD_CMD "${TMP_INFO[xmrig]}" "${PKG[link_html]}" &
		else
			$DOWNLOAD_CMD "${TMP_INFO[xmrig]}" "${PKG[link_api]}" &
		fi
	fi

	# WAIT FOR THREADS
	local JOB_LIST=$(jobs -p)
	if [[ $JOB_LIST ]]; then
		log::debug "waiting for download threads to complete"
		if ! wait -n; then
			print::exit "Update failure - could not connect to GitHub"
		fi
	fi

	# FILTER RESULT AND PRINT
	# monero
	# filter result
	if [[ $MONERO_VER ]]; then
		struct::pkg monero
		if [[ $HTML_MODE = true ]]; then
			SCRATCH=($(grep -o -m 1 "/${PKG[author]}/${PKG[name]}/releases/tag/.*\"" "${TMP_INFO[monero]}"))
			INFO="${SCRATCH[0]}"
			INFO="${INFO//*tag\/}"
			INFO="${INFO//\"}"
		else
			INFO="$(grep -m1 "tag_name" "${TMP_INFO[monero]}")"
			INFO="${INFO//*: }"
			INFO="${INFO//\"}"
			INFO="${INFO//,}"
		fi
		# print result and update state
		if [[ $MONERO_VER = "${INFO}" ]]; then
			printf "${BWHITE}%s${BGREEN}%s\n" \
				"Monero      | " "$MONERO_VER"
		else
			sed -i "s/MONERO_OLD=.*/MONERO_OLD=true/" "$STATE"
			UPDATE_FOUND=true
			printf "${BWHITE}%s${BRED}%s${BWHITE}%s${BGREEN}%s\n" \
				"Monero      | " "$MONERO_VER " "-> " "$INFO"
		fi
	fi

	# p2pool
	# filter result
	if [[ $P2POOL_VER ]]; then
		struct::pkg p2pool
		if [[ $HTML_MODE = true ]]; then
			SCRATCH=($(grep -o -m 1 "/${PKG[author]}/${PKG[name]}/releases/tag/.*\"" "${TMP_INFO[p2pool]}"))
			INFO="${SCRATCH[0]}"
			INFO="${INFO//*tag\/}"
			INFO="${INFO//\"}"
		else
			INFO="$(grep -m1 "tag_name" "${TMP_INFO[p2pool]}")"
			INFO="${INFO//*: }"
			INFO="${INFO//\"}"
			INFO="${INFO//,}"
		fi
		# print result and update state
		if [[ $P2POOL_VER = "${INFO}" ]]; then
			printf "${BWHITE}%s${BGREEN}%s\n" \
				"P2Pool      | " "$P2POOL_VER"
		else
			sed -i "s/P2POOL_OLD=.*/P2POOL_OLD=true/" "$STATE"
			UPDATE_FOUND=true
			printf "${BWHITE}%s${BRED}%s${BWHITE}%s${BGREEN}%s\n" \
				"P2Pool      | " "$P2POOL_VER " "-> " "$INFO"
		fi
	fi

	# xmrig
	# filter result
	if [[ $XMRIG_VER ]]; then
		struct::pkg xmrig
		if [[ $HTML_MODE = true ]]; then
			SCRATCH=($(grep -o -m 1 "/${PKG[author]}/${PKG[name]}/releases/tag/.*\"" "${TMP_INFO[xmrig]}"))
			INFO="${SCRATCH[0]}"
			INFO="${INFO//*tag\/}"
			INFO="${INFO//\"}"
		else
			INFO="$(grep -m1 "tag_name" "${TMP_INFO[xmrig]}")"
			INFO="${INFO//*: }"
			INFO="${INFO//\"}"
			INFO="${INFO//,}"
		fi
		# print result and update state
		if [[ $XMRIG_VER = "${INFO}" ]]; then
			printf "${BWHITE}%s${BGREEN}%s\n" \
				"XMRig       | " "$XMRIG_VER"
		else
			sed -i "s/XMRIG_OLD=.*/XMRIG_OLD=true/" "$STATE"
			UPDATE_FOUND=true
			printf "${BWHITE}%s${BRED}%s${BWHITE}%s${BGREEN}%s\n" \
				"XMRig       | " "$XMRIG_VER " "-> " "$INFO"
		fi
	fi

	# END
	if [[ $UPDATE_FOUND ]]; then
		echo
		printf "${BWHITE}%s${BRED}%s${BWHITE}%s${OFF}\n" \
			"Updates found, type: " \
			"[monero-bash upgrade] " \
			"to upgrade all packages"
		printf "${BWHITE}%s${BRED}%s${BWHITE}%s${OFF}\n" \
			"Or type: " \
			"[monero-bash <package>] " \
			"to upgrade a specific package"
	else
		print::updated
	fi

	log::debug "update() finished"
	return 0
}
