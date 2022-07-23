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
	log::debug "starting ${FUNCNAME}()"
	char WALLET_TYPE WALLET_NAME

	# WALLET TYPES
	while :; do
		while :; do
			echo
			printf "${BPURPLE}%s${OFF}%s${BRED}%s${OFF}\n" \
				"--generate-new-wallet         " "| " "[new]" \
				"--generate-from-view-key      " "| " "[view]" \
				"--restore-from-seed           " "| " "[seed]" \
				"--generate-from-json          " "| " "[json]" \
				"--generate-from-spend-key     " "| " "[spend]" \
				"--generate-from-device        " "| " "[device]" \
				"--generate-from-keys          " "| " "[private]" \
				"--generate-from-multisig-keys " "| " "[multisig]" \
				""
			printf "${BYELLOW}%s${OFF}" "Select which method to use: "

			read -r WALLET_TYPE
			case "$WALLET_TYPE" in
				--generate-new-wallet|*new*)           WALLET_TYPE=new;break;;
				--generate-from-view-key|*view*)       WALLET_TYPE=view;break;;
				--restore-from-seed|*seed*)            WALLET_TYPE=seed;break;;
				--generate-from-json|*json*)           WALLET_TYPE=json;break;;
				--generate-from-spend-key|*spend*)     WALLET_TYPE=spend;break;;
				--generate-from-device|*device*)       WALLET_TYPE=device;break;;
				--generate-from-keys|*private*)        WALLET_TYPE=private;break;;
				--generate-from-multisig-keys|*multi*) WALLET_TYPE=multisig;break;;
				*) print::error "Invalid method!"
			esac
		done
		printf "${BWHITE}%s${BRED}%s${BWHITE}%s${OFF}" \
			"Create wallet type: " \
			"[${WALLET_TYPE}]" \
			"? (Y/n) "
		if ask::yes; then
			break
		fi
	done

	# Wallet name
	while :; do
		printf "${BWHITE}%s${OFF}" "Wallet name: "
		read -r WALLET_NAME
		case "$WALLET_NAME" in
			"") print::error "Empty input";;
			*)  break;;
		esac
	done

	# log::debug
	log::debug "creating wallet [$WALLET_NAME] with type [$WALLET_TYPE]"

	# Create files within /.monero-bash/
	cd "$DOT"

	# CHECK FOR MONERO
	safety::package monero

	# Case wallet type
	case "$WALLET_TYPE" in
	new)
			"$PKG_MONERO/monero-wallet-cli" \
			--generate-new-wallet "$WALLETS/$WALLET_NAME" \
			--config-file "$CONFIG_MONEROD"
			;;
	view)
			"$PKG_MONERO/monero-wallet-cli" \
			--generate-from-view-key "$WALLETS/$WALLET_NAME" \
			--config-file "$CONFIG_MONEROD"
			;;
	seed)
			"$PKG_MONERO/monero-wallet-cli" \
			--generate-new-wallet "$WALLETS/$WALLET_NAME" \
			--config-file "$CONFIG_MONEROD" \
			--restore-from-seed
			;;
	json)
			"$PKG_MONERO/monero-wallet-cli" \
			--generate-from-json "$WALLETS/$WALLET_NAME" \
			--config-file "$CONFIG_MONEROD"
			;;
	spend)
			"$PKG_MONERO/monero-wallet-cli" \
			--generate-from-spend-key "$WALLETS/$WALLET_NAME" \
			--config-file "$CONFIG_MONEROD"
			;;
	device)
			"$PKG_MONERO/monero-wallet-cli" \
			--generate-from-device "$WALLETS/$WALLET_NAME" \
			--config-file "$CONFIG_MONEROD"
			;;
	private)
			"$PKG_MONERO/monero-wallet-cli" \
			--generate-from-keys "$WALLETS/$WALLET_NAME" \
			--config-file "$CONFIG_MONEROD"
			;;
	multisig)
			"$PKG_MONERO/monero-wallet-cli" \
			--generate-from-multisig-keys "$WALLETS/$WALLET_NAME" \
			--config-file "$CONFIG_MONEROD"
			;;
	esac
	return 0
}
