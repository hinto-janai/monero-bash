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

# wallet selection screen
wallet::select() {
	log::debug "starting wallet selection"
	___BEGIN___ERROR___TRACE___

	char WALLET_SELECTION
	local i

	while :; do
	# SELECT/CREATE WALLET
	printf "${BYELLOW}%s${OFF}%s${BRED}%s${OFF}%s" \
		"Select a wallet " \
		"or " \
		"[new]" \
		": "
	read -r WALLET_SELECTION
	for i in ${WALLET_LIST_ALL[@]}; do
		[[ $WALLET_SELECTION = "$i" ]] && break
	done
	case "$WALLET_SELECTION" in
		"$i") break;;
		"")   print::error "Empty input";;
		*)    print::error "Wallet not found";;
	esac
	done

	# WALLET NAME COLLISION
	if [[ $i = new || $i = New || $i = NEW ]]; then
		while :; do
			printf "${BWHITE}%s\n${OFF}%s" \
				"Wallet name is similar to option..." \
				"SELECT or CREATE? "
			local SELECT_CREATE
			read -r SELECT_CREATE
			case $SELECT_CREATE in
			select|Select|SELECT)
				printf "${BWHITE}%s${BRED}%s${OFF}\n" \
				"Selecting " \
				"[$WALLET_SELECTION]"
				break
				;;
			create|Create|CREATE)
				printf "${BWHITE}%s${BRED}%s${BWHITE}%s${OFF}\n" \
				"Creating a" \
				"[new] " \
				"wallet"
				wallet::create
				exit
				;;
			*) print::error "Invalid option!" ;;
			esac
		done
	fi

	# WALLET PASS
	wallet::password

	# CHECK FOR MONERO
	safety::package monero

	# START WALLET
	wallet::start

	___ENDOF___ERROR___TRACE___
	return 0
}
