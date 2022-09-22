# This file is part of [monero-bash]
#
# Copyright (c) 2022 hinto.janaiyo
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
#
# Parts of this project are originally:
# Copyright (c) 2019-2022, jtgrassie
# Copyright (c) 2014-2022, The Monero Project
# Copyright (c) 2011-2022, Dominic Tarr
#
# Parts of this project are licensed under GPLv2:
# Copyright (c) ????-2022, Tamas Szerb <toma@rulez.org>
# Copyright (c) 2008-2022, Robert Hogan <robert@roberthogan.net>
# Copyright (c) 2008-2022, David Goulet <dgoulet@ev0ke.net>
# Copyright (c) 2008-2022, Alex Xu (Hello71) <alex_y_xu@yahoo.ca>


# Monero Wallet Functions

wallet_Start()
{
	# CHECK IF MISSING BINARY
	missing_MoneroCLI

	# AUTO MONEROD START
	[[ $AUTO_START_DAEMON = "true" ]]&& define_Monero&&process_Start

	# CD INTO .monero-bash SO FILES/LOGS GET CREATED THERE
	cd "$dotMoneroBash"

	# START NORMALLY
	"$binMonero/monero-wallet-cli" \
		--wallet-file "$wallets/$walletSelection" \
		--password "$walletPassword" \
		--config-file "$config/monero-wallet-cli.conf"
		error_Exit "Could not start monero-wallet-cli"

	# AUTO MONEROD STOP
	[[ $AUTO_STOP_DAEMON = "true" ]]&& define_Monero&&process_Stop
	exit 0
}

# this much better wallet::create() function was
# stolen from [monero-bash v2.0.0] and slightly
# modified to work with the crusty old code
# that is [monero-bash v1.x.x] :D
# it allows for creation of all wallet types.
wallet::create() {
	# CHECK IF MISSING BINARY
	missing_MoneroCLI

	# CD INTO .monero-bash SO FILES/LOGS GET CREATED THERE
	cd "$dotMoneroBash"

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
			printf "${BWHITE}%s${OFF}" "Which wallet type? "

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
				*) print_Error "Invalid wallet type!"
			esac
		done
		printf "${BWHITE}%s${BRED}%s${BWHITE}%s${OFF}" \
			"Create wallet type " \
			"[${WALLET_TYPE}]" \
			"? (Y/n) "
		read yn
		case $yn in
			y|Y|yes|Yes|YES|""|" ") break;;
			*) :;;
		esac
	done

	# Wallet name
	while :; do
		if [[ $WALLET_TYPE = json ]]; then
			printf "${BWHITE}%s${OFF}" "JSON file path: "
			read -r WALLET_NAME
			case "$WALLET_NAME" in
				"")    print_Error "Empty input";;
				*)     printf "\n${BPURPLE}%s${BWHITE}%s${OFF}\n" "Using file " "[$WALLET_NAME]"; break;;
			esac
		else
			printf "${BWHITE}%s${OFF}" "Wallet name: "
			read -r WALLET_NAME
			case "$WALLET_NAME" in
				"")    print_Error "Empty input";;
				*" "*) print_Error "Wallet name cannot have spaces";;
				*)     printf "\n${BPURPLE}%s${BWHITE}%s${OFF}\n" "Creating wallet " "[$WALLET_NAME]"; break;;
			esac
		fi
	done

	# Case wallet type
	if case "$WALLET_TYPE" in
	new)
			"$binMonero/monero-wallet-cli" \
			--generate-new-wallet "$wallets/$WALLET_NAME" \
			--config-file "$config/monero-wallet-cli.conf"
			;;
	view)
			"$binMonero/monero-wallet-cli" \
			--generate-from-view-key "$wallets/$WALLET_NAME" \
			--config-file "$config/monero-wallet-cli.conf"
			;;
	seed)
			"$binMonero/monero-wallet-cli" \
			--generate-new-wallet "$wallets/$WALLET_NAME" \
			--config-file "$config/monero-wallet-cli.conf" \
			--restore-from-seed
			;;
	json)
			"$binMonero/monero-wallet-cli" \
			--generate-from-json "$WALLET_NAME" \
			--config-file "$config/monero-wallet-cli.conf"
			;;
	spend)
			"$binMonero/monero-wallet-cli" \
			--generate-from-spend-key "$wallets/$WALLET_NAME" \
			--config-file "$config/monero-wallet-cli.conf"
			;;
	device)
			"$binMonero/monero-wallet-cli" \
			--generate-from-device "$wallets/$WALLET_NAME" \
			--config-file "$config/monero-wallet-cli.conf"
			;;
	private)
			"$binMonero/monero-wallet-cli" \
			--generate-from-keys "$wallets/$WALLET_NAME" \
			--config-file "$config/monero-wallet-cli.conf"
			;;
	multisig)
			"$binMonero/monero-wallet-cli" \
			--generate-from-multisig-keys "$wallets/$WALLET_NAME" \
			--config-file "$config/monero-wallet-cli.conf"
			;;
	esac; then
		exit 0
	else
		print_Error "monero-wallet-cli error has occurred"
		exit 1
	fi
}

wallet_Count()
{
	walletCount="$(ls "$wallets" | grep -v ".keys" | wc -l)"
	BYELLOW; echo -n "$walletCount " ;BWHITE
	if [[ $walletCount = 1 ]]; then
		echo "wallet found:"
		echo
	elif [[ $walletCount -gt 1 ]]; then
		echo "wallets found: "
		echo
	elif [[ $walletCount = 0 ]]; then
		echo "wallets found"
	fi
}

wallet_List()
{
	walletList=($(ls "$wallets" | grep -v ".keys"))
	wallet_list_pretty()
	{
		local walletAmount=0
		local walletChar=0
		for i in ${walletList[*]}; do
			# wrap line after wallet names
			# are > 4 or if exceeds 40
			walletAmount=$((walletAmount + 1))
			walletChar=$((walletChar + ${#i} + 4)) #+4 accounts for '[]  '
			if [[ $walletAmount -gt 4 || $walletChar -ge 40 ]]; then
				walletAmount=0
				walletChar=0
				printf "${OFF}[${BWHITE}%s${OFF}]  \n\n" "${i}"
			else
				printf "${OFF}[${BWHITE}%s${OFF}]  " "${i}"
			fi
		done
	}
	# print nice spacing regardless if wallets exist or not
	[[ $walletList ]] && echo "$(wallet_list_pretty)"
	echo
}
