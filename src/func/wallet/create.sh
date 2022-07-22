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

# create a new wallet
wallet::create() {
	log::debug "creating new wallet"
	char WALLET_TYPE

	# WALLET TYPES
	while :; do
	printf "${BYELLOW}%s\n" "Select which method to use to create a new wallet:"
	printf "${BRED}%s${OFF}%s\n" \
		"[new]          | --generate-new-wallet" \
		"[view]         | --generate-from-view-key" \
		"[seed]         | --restore-from-seed" \
		"[json]         | --generate-from-json" \
		"[spend]        | --generate-from-spend-key" \
		"[device]       | --generate-from-device" \
		"[private]      | --generate-from-keys" \
		"[multisig]     | --generate-from-multisig-keys"

		read -r WALLET_TYPE
		case "$WALLET_TYPE" in
			*new*)     WALLET_TYPE=new     ;break;;
			*view*)    WALLET_TYPE=view    ;break;;
			*seed*)    WALLET_TYPE=seed    ;break;;
			*json*)    WALLET_TYPE=json    ;break;;
			*spend*)   WALLET_TYPE=spend   ;break;;
			*device*)  WALLET_TYPE=device  ;break;;
			*private*) WALLET_TYPE=private ;break;;
			*multi*)   WALLET_TYPE=multisig;break;;
			*) print::error "Invalid method!"
		esac
		printf "${BWHITE}%s${BRED}%s\n" \
			"Create wallet type: " \
			"[${WALLET_TYPE}]? (Y/n) "
		if ask::yes; then
			break
		fi
	done

	# Create files within /.monero-bash/
	cd "$DOT"

	# Case wallet type
	case "$WALLET_TYPE" in
	new)
			"$PKG_MONERO/monero-wallet-cli" \
			--generate-new-wallet "$WALLETS/$WALLET_SELECTION" \
			--config-file "$CONFIG_MONEROD"
			;;
	view)
			"$PKG_MONERO/monero-wallet-cli" \
			--generate-from-view-key "$WALLETS/$WALLET_SELECTION" \
			--config-file "$CONFIG_MONEROD"
			;;
	seed)
			"$PKG_MONERO/monero-wallet-cli" \
			--generate-new-wallet "$WALLETS/$WALLET_SELECTION" \
			--config-file "$CONFIG_MONEROD" \
			--restore-from-seed
			;;
	json)
			"$PKG_MONERO/monero-wallet-cli" \
			--generate-from-json "$WALLETS/$WALLET_SELECTION" \
			--config-file "$CONFIG_MONEROD"
			;;
	spend)
			"$PKG_MONERO/monero-wallet-cli" \
			--generate-from-spend-key "$WALLETS/$WALLET_SELECTION" \
			--config-file "$CONFIG_MONEROD"
			;;
	device)
			"$PKG_MONERO/monero-wallet-cli" \
			--generate-from-device "$WALLETS/$WALLET_SELECTION" \
			--config-file "$CONFIG_MONEROD"
			;;
	private)
			"$PKG_MONERO/monero-wallet-cli" \
			--generate-from-keys "$WALLETS/$WALLET_SELECTION" \
			--config-file "$CONFIG_MONEROD"
			;;
	multisig)
			"$PKG_MONERO/monero-wallet-cli" \
			--generate-from-multisig-keys "$WALLETS/$WALLET_SELECTION" \
			--config-file "$CONFIG_MONEROD"
			;;
	esac
	return 0
}
