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

# hooks to run pre-upgrade
pkg::hook::pre() {
	log::debug "starting ${FUNCNAME}()"

	if [[ $MONERO_BASH_OLD = true ]]; then
		pkg::hook::pre::bash
	else
		log::ok "no hooks found"
	fi
}

# hooks to run post-upgrade
# order:
# - update state
# - individual pkgs
# - create config files
# - create systemd files
# - refresh systemd
# - set permissions
pkg::hook::post() {
	log::debug "starting ${FUNCNAME}()"

	# state update
	log::debug "recreating old state in: $STATE"
	echo "${HOOK_BASH_STATE[@]}" > "$STATE"

	# individual package hooks
	[[ $MONERO_BASH_OLD = true ]] && pkg::hook::post::bash

	# configs/system
	if [[ $MONERO_OLD = true ]]; then
		struct::pkg monero
		pkg::hook::post::config
		pkg::hook::post::systemd
	fi
	if [[ $P2POOL_OLD = true ]]; then
		struct::pkg monero
		pkg::hook::post::config
		pkg::hook::post::systemd
	fi
	if [[ $XMRIG_OLD = true ]]; then
		struct::pkg monero
		pkg::hook::post::config
		pkg::hook::post::systemd
	fi

	# refresh systemd
	if [[ $MONERO_OLD = true || $P2POOL_OLD = true || $XMRIG_OLD = true ]]; then
		log::prog "Reloading systemd..."
		systemd::reload
		log::ok "Reloaded systemd"
	fi

	# set permissions
	log::prog "Setting permissions..."
	sudo chmod -R 770 "$PACKAGES"
	sudo chown -R "monero-bash:$USER" "$PACKAGES"
	log::ok "Set permissions"
}

# create config files for packages.
pkg::hook::post::config() {
	log::debug "starting ${FUNCNAME}() for: ${PKG[pretty]}"

	log::prog "${PKG[pretty]} | config file check: ${PKG[conf_name]}..."
	if [[ -e ${PKG[config]} ]]; then
		log::ok "${PKG[pretty]} | config file found: ${PKG[conf_name]}"
	else
		log::debug "no config found, copying $SRC_CONFIG/${PKG[conf_name]} to $CONFIG"
		cp "$SRC_CONFIG/${PKG[conf_name]}" "$CONFIG"
		log::ok "${PKG[pretty]} | config file installed: ${PKG[conf_name]}"
	fi

	# special check for monero (two confs)
	if [[ ${PKG[name]} = monero ]]; then
		log::prog "${PKG[pretty]} | config file check: monero-wallet-cli.conf..."
		if [[ -e "$CONFIG/monero-wallet-cli.conf" ]]; then
			log::ok "${PKG[pretty]} | config file found: monero-wallet-cli.conf"
		else
			log::debug "no config found, copying $SRC_CONFIG/monero-wallet-cli.conf to $CONFIG"
			cp "$SRC_CONFIG/${PKG[conf_name]}" "$CONFIG"
			log::ok "${PKG[pretty]} | config file installed: monero-wallet-cli.conf"
		fi
	fi
}

# create systemd files for packages.
pkg::hook::post:systemd() {
	log::debug "starting ${FUNCNAME}() for: ${PKG[pretty]}"

	log::prog "${PKG[pretty]} | systemd service check: ${PKG[service]}..."
	if [[ -e "$SYSTEMD/${PKG[service]}" ]]; then
		log::ok "${PKG[pretty]} | systemd service found: ${PKG[service]}"
	else
		log::debug "no systemd service found, creating: $SYSTEMD/${PKG[service]}"
		systemd::create
		log::ok "${PKG[pretty]} | systemd service installed: ${PKG[service]}"
	fi
}

# pre-upgrade hook for [monero-bash].
# save the state file.
pkg::hook::pre::bash() {
	log::debug "starting ${FUNCNAME}()"
	log::prog "monero-bash | saving state..."

	map HOOK_BASH_STATE
	mapfile HOOK_BASH_STATE < "$STATE"

	log::ok "monero-bash | state saved"
}

# post-upgrade hook for [monero-bash].
# compare diffs between old and new text files.
# looks for [monero-bash.conf], [state] and [p2pool.conf]
pkg::hook::post::bash() {
	log::debug "starting ${FUNCNAME}()"

	unset -v DIFF
	local DIFF
	local IFS=$'\n' i

	# [monero-bash.conf]
	log::prog "monero-bash | diff for: monero-bash.conf..."
	if DIFF=$(diff --side-by-side --left-column "$CONFIG_MONERO_BASH" "${TMP_PKG[bash_pkg]}/config/monero-bash.conf"); then
		# diff exits 0 for no diff
		log::ok "monero-bash | no diff: monero-bash.conf"
	else
		# diff exits 1 if diff found
		log::debug "--- monero-bash.conf diff ---"
		for i in $DIFF; do
			log::debug "$i"
		done
		# filter out diffs
		DIFF=$(echo "$DIFF" | sed -e 's/[[:space:]]\+(//g' -e 's/[[:space:]]\+|.*$//g' -e 's/[[:space:]]\+>\t//g' -e 's/[[:space:]]\+>$//g')
		# apply diff
		echo "$DIFF" > "$CONFIG_MONERO_BASH"
		log::ok "monero-bash | diff applied: monero-bash.conf"
	fi

	unset -v DIFF
	local DIFF

	# [state]
	log::prog "monero-bash | diff for: state..."
	if DIFF=$(diff --side-by-side --left-column "$STATE" "${TMP_PKG[bash_pkg]}/txt/state"); then
		# diff exits 0 for no diff
		log::ok "monero-bash | no diff: state"
	else
		# diff exits 1 if diff found
		log::debug "--- state diff ---"
		for i in $DIFF; do
			log::debug "$i"
		done
		# filter out diffs
		DIFF=$(echo "$DIFF" | sed -e 's/[[:space:]]\+(//g' -e 's/[[:space:]]\+|.*$//g' -e 's/[[:space:]]\+>\t//g' -e 's/[[:space:]]\+>$//g')
		# apply diff
		echo "$DIFF" > "$STATE"
		log::ok "monero-bash | diff applied: state"
	fi

	unset -v DIFF
	local DIFF

	# [p2pool.conf]
	[[ $P2POOL_VER ]] || return 0
	log::prog "p2pool | diff for: p2pool.conf..."
	if DIFF=$(diff --side-by-side --left-column "$CONFIG_P2POOL" "${TMP_PKG[bash_pkg]}/config/p2pool.conf"); then
		# diff exits 0 for no diff
		log::debug "p2pool | no diff: p2pool.conf"
	else
		# diff exits 1 if diff found
		log::debug "--- p2pool.conf diff ---"
		for i in $DIFF; do
			log::debug "$i"
		done
		# filter out diffs
		DIFF=$(echo "$DIFF" | sed -e 's/[[:space:]]\+(//g' -e 's/[[:space:]]\+|.*$//g' -e 's/[[:space:]]\+>\t//g' -e 's/[[:space:]]\+>$//g')
		# apply diff
		echo "$DIFF" > "$CONFIG_P2POOL"
		log::ok "p2pool | diff applied: p2pool.conf"
	fi

	return 0
}
