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


# Monero Wallet Functions

wallet_Start()
{
	# CHECK IF MISSING BINARY
	missing_MoneroCLI

	# AUTO MONEROD START
	[[ $AUTO_START_DAEMON = "true" ]]&& define_Monero&&process_Start

	# CD INTO .monero-bash SO FILES/LOGS GET CREATED THERE
	cd "$dotMoneroBash"

	# NORMAL WALLET CREATION
	if [[ $createWallet = "true" ]]; then
		"$binMonero/monero-wallet-cli" \
			--generate-new-wallet "$wallets/$walletName" \
			--password "$walletPassword" \
			--mnemonic-language "$seedLanguage" \
			--config-file "$config/monero-wallet-cli.conf"
			error_Exit "Could not start monero-wallet-cli"

	# VIEW WALLET CREATION
	elif [[ $createView = "true" ]]; then
		"$binMonero/monero-wallet-cli" \
			--generate-from-view-key "$wallets/$walletName" \
			--password "$walletPassword" \
			--config-file "$config/monero-wallet-cli.conf"
			error_Exit "Could not start monero-wallet-cli"

	# WALLET RECOVERY WITH STANDARD SEED
	elif [[ $recoverWallet = "true" ]]; then
		"$binMonero/monero-wallet-cli" \
			--generate-new-wallet "$wallets/$walletName" \
			--password "$walletPassword" \
			--restore-from-seed \
			--electrum-seed "$walletSeed" \
			--config-file "$config/monero-wallet-cli.conf"
			error_Exit "Could not start monero-wallet-cli"
	else

	# IF NOT CREATING, START NORMALLY
		"$binMonero/monero-wallet-cli" \
			--wallet-file "$wallets/$walletSelection" \
			--password "$walletPassword" \
			--config-file "$config/monero-wallet-cli.conf"
			error_Exit "Could not start monero-wallet-cli"
	fi

	# AUTO MONEROD STOP
	[[ $AUTO_STOP_DAEMON = "true" ]]&& define_Monero&&process_Stop
	exit 0
}

wallet_Template()
{
	# WALLET NAME
	while true ;do
		$off; echo -n "New wallet name: " ;$iwhite
		read walletName
		if [[ "$walletName" = *" "* || "$walletName" = "" ]]; then
			print_Error "Wallet name cannot be empty or have spaces"
		else
			break
		fi
	done

	# WALLET PASS
	while true; do
		$off; echo -n "Wallet password: "
		read -s walletPassword
		echo
		$off; echo -n "Enter password again: "
		read -s walletPasswordAgain
		echo
		if [[ "$walletPassword" = "$walletPasswordAgain" ]]; then
			break
		else
			print_Error "Password was not the same!"
		fi
	done
}
wallet_Create()
{
	wallet_Template

	# WALLET SEED LANGUAGE
	while true ;do
		$ired; echo "Monero seed languages:" ;$iwhite
		print_SeedLanguageList
		$off; echo -n "Pick seed language: " ;$iwhite
		read seedLanguage
			case "$seedLanguage" in
				"0"|deutsch|Deutsch|german|German) seedLanguage="Deutsch" ;break ;;
				"1"|english|English) seedLanguage="English" ;break ;;
				"2"|español|Español|spanish|Spanish) seedLanguage="Español" ;break ;;
				"3"|français|Français|french|French) seedLanguage="Français" ;break ;;
				"4"|italiano|Italiano|italian|Italian) seedLanguage="Italiano" ;break ;;
				"5"|nederlands|Nederlands|dutch|Dutch) seedLanguage="Nederlands" ;break ;;
				"6"|português|Português|portuguese|Portuguese) seedLanguage="Português" ;break ;;
				"7"|"русский язык"|russian|Russian) seedLanguage="русский язык" ;break ;;
				"8"|日本語|にほんご|japanese|Japanese) seedLanguage="日本語" ;break ;;
				"9"|"简体中文(中国)"|"简体中文"|"简体中文 (中国)"|chinese|Chinese) seedLanguage="简体中文 (中国)" ;break ;;
				"10"|esperanto|Esperanto) seedLanguage="Esperanto" ;break ;;
				"11"|lojban|Lojban) seedLanguage="Lojban" ;break ;;
				*) print_Error "invalid input" ;;
			esac
		done

	# START monero-wallet-cli WITH CREATION VARIABLES SET
	$byellow; echo "Starting wallet..." ;$off
	createWallet="true"
	wallet_Start
}

# creation of view-only wallet
wallet_View()
{
	$bred; echo "Creating [view] wallet..." ;$off
	wallet_Template

	# START monero-wallet-cli WITH CREATION VARIABLES SET
	$byellow; echo "Starting wallet..." ;$off
	createView="true"
	wallet_Start
}

# recovery of wallet
wallet_Recover()
{
	$bred; echo "Recovering wallet..." ;$off
	wallet_Template

	# SEED INPUT
	while true ;do
		$off; echo -n "Seed (24/25 words): "
		read -r walletSeed ; echo
		case $walletSeed in
			"") print_Error "Empty input" ;;
			*)
				clear
				n=1
				for i in $walletSeed; do
					if [[ $n -lt 10 ]]; then
						printf "${n}  | %s\n" "${i} "
					else
						printf "${n} | %s\n" "${i} "
					fi
					((n++))
				done
				$bwhite; echo -n "Is this correct? (Y/n) "
				local YES_NO
				read -r YES_NO
				case $YES_NO in
					y|Y|yes|Yes|YES|"") clear; break;;
					*) echo;;
				esac
		esac
	done

	# CONFIRM SEED

	# START monero-wallet-cli WITH RECOVERY VARIABLES SET
	$byellow; echo "Starting wallet..." ;$off
	recoverWallet="true"
	wallet_Start
}

# if wallet name happens to be "new/view/recover"
wallet_Collision()
{
	$off; echo "Wallet name is similar to option..."
	while true ;do
	$iblue; printf "SELECT "
	$off; printf "or "
	$ired; printf "CREATE? " ;$off
	read selectCreate
		case $selectCreate in
			select|Select|SELECT)
				$off; echo "Selecting $walletSelection..."
				echo -n "Password: "
				read -s walletPassword && echo
				wallet_Start
				exit
				;;
			create|Create|CREATE)
				break
				;;
			*) print_Error "Invalid option" ;;
		esac
	done
}

wallet_Count()
{
	walletCount="$(ls "$wallets" | grep -v ".keys" | wc -l)"
	$byellow; echo -n "$walletCount " ;$bwhite
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
		for i in ${walletList[*]}; do
			printf "[${i}]  "
		done
	}
	# print nice spacing regardless if wallets exist or not
	if [[ $walletList = "" ]]; then
		echo
	else
		$bwhite; echo "$(wallet_list_pretty)"
		echo
	fi
}
