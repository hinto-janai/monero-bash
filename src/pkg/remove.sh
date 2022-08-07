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

### functions for removing packages

# prompt for removing packages
# uses variables from parse/options.sh
# continues to pkg::remove()
pkg::remove::prompt() {
	# CHECK FOR VERBOSE/FORCE
	if [[ $OPTION_VERBOSE = true ]]; then
		STD_LOG_DEBUG=true
		printf "${BPURPLE}%s${BWHITE}%s${OFF}\n" "!! " "Removing verbosely!"
	fi
	[[ $OPTION_YES = true ]] && printf "${BPURPLE}%s${BWHITE}%s${OFF}\n" "!! " "Removing automatically!"
	echo

	log::debug "starting"

	# CREATE REMOVE LIST
	local REMOVE_LIST || return 1
	if [[ $OPTION_BASH = true ]]; then
		printf "${BYELLOW}%s${OFF}%s\n${BYELLOW}%s${OFF}%s${BCYAN}%s${OFF}%s\n" \
			"!! " \
			"[monero-bash] ($MONERO_BASH_VER) cannot be removed normally" \
			"!! " \
			"Type: " \
			"[monero-bash uninstall] " \
			"to cleanly uninstall monero-bash from your system"
		exit 1
	fi
	[[ $OPTION_MONERO = true ]] && REMOVE_LIST="$REMOVE_LIST monero"
	[[ $OPTION_P2POOL = true ]] && REMOVE_LIST="$REMOVE_LIST p2pool"
	[[ $OPTION_XMRIG = true ]]  && REMOVE_LIST="$REMOVE_LIST xmrig"

	# CHECK IF PACKAGE IS INSTALLED
	if [[ $OPTION_MONERO = true && -z $MONERO_VER ]]; then
		printf "${OFF}%s\n" "[Monero] is not installed"
		REMOVE_LIST="${REMOVE_LIST//monero}"
	fi
	if [[ $OPTION_P2POOL = true && -z $P2POOL_VER ]]; then
		printf "${OFF}%s\n" "[P2Pool] is not installed"
		REMOVE_LIST="${REMOVE_LIST//p2pool}"
	fi
	if [[ $OPTION_XMRIG = true && -z $XMRIG_VER ]]; then
		printf "${OFF}%s\n" "[XMRig] is not installed"
		REMOVE_LIST="${REMOVE_LIST//xmrig}"
	fi

	# EXIT ON EMPTY LIST
	if [[ $REMOVE_LIST =~ ^[[:space:]]+$ || -z $REMOVE_LIST ]]; then
		log::debug "REMOVE_LIST is empty, exiting"
		exit 1
	fi

	# CREATE UI LIST
	local PROMPT_REMOVE_LIST i
	for i in $REMOVE_LIST; do
		case "$i" in
			monero) PROMPT_REMOVE_LIST="$PROMPT_REMOVE_LIST  [Monero]";;
			p2pool) PROMPT_REMOVE_LIST="$PROMPT_REMOVE_LIST  [P2Pool]";;
			xmrig) PROMPT_REMOVE_LIST="$PROMPT_REMOVE_LIST  [XMRig]";;
		esac
	done

	# PROMPT
	printf "${BRED}%s${BWHITE}%s${OFF}%s\n${BRED}%s\n${BRED}%s${BWHITE}%s" \
		"|| " \
		"Packages to remove: " \
		"$PROMPT_REMOVE_LIST" \
		"|| " \
		"|| " \
		"Continue with removal? (y/N) "
	# AUTO (OPTION_YES)
	if [[ $OPTION_YES = true ]]; then
		printf "${BBLUE}%s${OFF}\n" "AUTOMATIC REMOVAL STARTING"
	else
		if ask::no; then
			printf "${BGREEN}%s${OFF}%s\n" "|| " "Canceling installation"
			exit 1
		fi
	fi

	# SUDO
	if ! ask::sudo; then
		print::exit "sudo is required"
	fi

	# START REMOVAL
	for i in $REMOVE_LIST; do
		struct::pkg $i
		pkg::remove
	done
	exit 0
}

# pkg::remove packages
# called from pkg::remove::prompt()
pkg::remove() {
	log::debug "${PKG[pretty]} | starting"
	log::debug "Ignoring INT signal for safety"
	trap "" INT
	print::pkg::remove

	# SET TRAP
	log::debug "Setting trap to continue removal on EXIT signal"
	trap 'trap::remove' EXIT

	# REMOVE PKG DIRECTORY
	log::prog "Removing ${PKG[directory]}..."
	rm -rf "${PKG[directory]}"
	log::ok "Removed ${PKG[directory]}"

	# REMOVE SYSTEMD SERVICE
	log::prog "Removing ${PKG[service]}..."
	sudo rm -f "${SYSTEMD:?}/${PKG[service]:?}"
	log::ok "Removed ${PKG[service]}"

	# REMOVE CHANGELOG
	log::prog "Removing ${CHANGES:?}/${PKG[name]:?}..."
	rm -rf "${CHANGES:?}/${PKG[name]:?}"
	log::ok "Removed ${CHANGES:?}/${PKG[name]:?}"

	# UPDATE LOCAL STATE
	log::prog "Updating local state..."
	sudo sed \
		-i -e "s/${PKG[var]}_VER=.*/${PKG[var]}_VER=/" "$STATE" \
		-i -e "s/${PKG[var]}_OLD=.*/${PKG[var]}_OLD=\"true\"/" "$STATE"
	log::debug "STATE | ${PKG[var]}_VER -> null"
	log::debug "STATE | ${PKG[var]}_OLD -> true"
	log::ok "Updated local state"

	# FREE TRAP
	log::debug "Resetting INT and EXIT signals"
	trap - INT EXIT

	# RELOAD SYSTEMD
	log::prog "Reloading systemd..."
	systemd::reload
	log::ok "Reloaded systemd"

	# END
	log::debug "${PKG[pretty]} | removal OK"
	print::pkg::removed
	return 0
}