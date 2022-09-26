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

# fetch price data

price_Check()
{
	[[ $FAKE_HTTP_HEADERS = true ]] && header_Random
	[[ $USE_TOR = true ]] && { torsocks_init; echo; } || prompt_PriceAPI_IP
	local PRICE LINK="https://min-api.cryptocompare.com/data/pricemultifull?fsyms=XMR&tsyms=USD,EUR,JPY,GBP,CHF,CAD,AUD,ZAR,BTC,ETH,BCH,ZEC,BNB,XRP,ADA,SOL,DOT,DOGE,TRX,ETC,LTC,LINK,XLM,ALGO"
	# use TOR if enabled
	if [[ $USE_TOR = true ]]; then
		if [[ $WGET_GZIP = true ]]; then
			PRICE=$(torsocks_func wget -qO- "${WGET_HTTP_HEADERS[@]}" -e robots=off "$LINK" | gzip -d)
			code_Wget
		else
			PRICE=$(torsocks_func wget -qO- "${WGET_HTTP_HEADERS[@]}" -e robots=off "$LINK")
			code_Wget
		fi
	else
		if [[ $WGET_GZIP = true ]]; then
			PRICE=$(wget -qO- "${WGET_HTTP_HEADERS[@]}" -e robots=off "$LINK" | gzip -d)
			code_Wget
		else
			PRICE=$(wget -qO- "${WGET_HTTP_HEADERS[@]}" -e robots=off "$LINK")
			code_Wget
		fi
	fi
	# check for API errors
	case "$PRICE" in
		*"rate limit"*)
			print_Error "<cryptocompare.com> API rate-limit error"
			[[ $USE_TOR = true ]] && print_Error "Restarting Tor may help: <sudo systemctl restart tor.service>"
			exit 1
			;;
		""|" ")
			print_Error_Exit "Could not get data from <cryptocompare.com> API"
			[[ $USE_TOR = true ]] && print_Error "Restarting Tor may help: <sudo systemctl restart tor.service>"
			exit 1
			;;
	esac

	# declare JSON values into variables
	local $(echo "$PRICE" | json::var | grep "RAW.*PRICE\|RAW.*HIGHDAY\|RAW.*LOWDAY\|RAW.*CHANGEPCTDAY\|RAW_XMR_USD_LASTUPDATE\|RAW_XMR_BTC_LASTUPDATE")
	# timestamp conversion
	RAW_XMR_USD_LASTUPDATE=$(printf "%(%F %T)T" "$RAW_XMR_USD_LASTUPDATE")
	RAW_XMR_BTC_LASTUPDATE=$(printf "%(%F %T)T" "$RAW_XMR_BTC_LASTUPDATE")
	# fiat
	local FIAT=$(\
	printf "%s${BWHITE}${UWHITE}%s${OFF}%s\n" \
		"| " "Fiat Currency        | Symbol | Price | Day High | Day Low | Day Change %" " |"
	printf "%s\n" \
		"| United States Dollar | USD    | ${RAW_XMR_USD_PRICE:0:7} | ${RAW_XMR_USD_HIGHDAY:0:7} | ${RAW_XMR_USD_LOWDAY:0:7} | ${RAW_XMR_USD_CHANGEPCTDAY:0:5}% |" \
		"| Great British Pound  | GBP    | ${RAW_XMR_GBP_PRICE:0:7} | ${RAW_XMR_GBP_HIGHDAY:0:7} | ${RAW_XMR_GBP_LOWDAY:0:7} | ${RAW_XMR_GBP_CHANGEPCTDAY:0:5}% |" \
		"| European Euro        | EUR    | ${RAW_XMR_EUR_PRICE:0:7} | ${RAW_XMR_EUR_HIGHDAY:0:7} | ${RAW_XMR_EUR_LOWDAY:0:7} | ${RAW_XMR_EUR_CHANGEPCTDAY:0:5}% |" \
		"| Japanese Yen         | JPY    | ${RAW_XMR_JPY_PRICE:0:7} | ${RAW_XMR_JPY_HIGHDAY:0:7} | ${RAW_XMR_JPY_LOWDAY:0:7} | ${RAW_XMR_JPY_CHANGEPCTDAY:0:5}% |" \
		"| Swiss Franc          | CHF    | ${RAW_XMR_CHF_PRICE:0:7} | ${RAW_XMR_CHF_HIGHDAY:0:7} | ${RAW_XMR_CHF_LOWDAY:0:7} | ${RAW_XMR_CHF_CHANGEPCTDAY:0:5}% |" \
		"| Canadian Dollar      | CAD    | ${RAW_XMR_CAD_PRICE:0:7} | ${RAW_XMR_CAD_HIGHDAY:0:7} | ${RAW_XMR_CAD_LOWDAY:0:7} | ${RAW_XMR_CAD_CHANGEPCTDAY:0:5}% |" \
		"| Australian Dollar    | AUD    | ${RAW_XMR_AUD_PRICE:0:7} | ${RAW_XMR_AUD_HIGHDAY:0:7} | ${RAW_XMR_AUD_LOWDAY:0:7} | ${RAW_XMR_AUD_CHANGEPCTDAY:0:5}% |" \
		"| South African Rand   | ZAR    | ${RAW_XMR_ZAR_PRICE:0:7} | ${RAW_XMR_ZAR_HIGHDAY:0:7} | ${RAW_XMR_ZAR_LOWDAY:0:7} | ${RAW_XMR_ZAR_CHANGEPCTDAY:0:5}% |")
	# cryptocurrency
	local CRYPTO=$(\
	printf "%s${BWHITE}${UWHITE}%s${OFF}%s\n" \
		"| " "Cryptocurrency | Symbol | Price | Day High | Day Low | Day Change %" " |"
	printf "%s\n" \
		"| Bitcoin          | BTC  | ${RAW_XMR_BTC_PRICE:0:7}  | ${RAW_XMR_BTC_HIGHDAY:0:7}  | ${RAW_XMR_BTC_LOWDAY:0:7}  | ${RAW_XMR_BTC_CHANGEPCTDAY:0:5}%  |" \
		"| Ethereum         | ETH  | ${RAW_XMR_ETH_PRICE:0:7}  | ${RAW_XMR_ETH_HIGHDAY:0:7}  | ${RAW_XMR_ETH_LOWDAY:0:7}  | ${RAW_XMR_ETH_CHANGEPCTDAY:0:5}%  |" \
		"| BNB              | BNB  | ${RAW_XMR_BNB_PRICE:0:7}  | ${RAW_XMR_BNB_HIGHDAY:0:7}  | ${RAW_XMR_BNB_LOWDAY:0:7}  | ${RAW_XMR_BNB_CHANGEPCTDAY:0:5}%  |" \
		"| Ripple           | XRP  | ${RAW_XMR_XRP_PRICE:0:7}  | ${RAW_XMR_XRP_HIGHDAY:0:7}  | ${RAW_XMR_XRP_LOWDAY:0:7}  | ${RAW_XMR_XRP_CHANGEPCTDAY:0:5}%  |" \
		"| Cardano          | ADA  | ${RAW_XMR_ADA_PRICE:0:7}  | ${RAW_XMR_ADA_HIGHDAY:0:7}  | ${RAW_XMR_ADA_LOWDAY:0:7}  | ${RAW_XMR_ADA_CHANGEPCTDAY:0:5}%  |" \
		"| Solana           | SOL  | ${RAW_XMR_SOL_PRICE:0:7}  | ${RAW_XMR_SOL_HIGHDAY:0:7}  | ${RAW_XMR_SOL_LOWDAY:0:7}  | ${RAW_XMR_SOL_CHANGEPCTDAY:0:5}%  |" \
		"| Polkadot         | DOT  | ${RAW_XMR_DOT_PRICE:0:7}  | ${RAW_XMR_DOT_HIGHDAY:0:7}  | ${RAW_XMR_DOT_LOWDAY:0:7}  | ${RAW_XMR_DOT_CHANGEPCTDAY:0:5}%  |" \
		"| Dogecoin         | DOGE | ${RAW_XMR_DOGE_PRICE:0:7} | ${RAW_XMR_DOGE_HIGHDAY:0:7} | ${RAW_XMR_DOGE_LOWDAY:0:7} | ${RAW_XMR_DOGE_CHANGEPCTDAY:0:5}% |" \
		"| TRON             | TRX  | ${RAW_XMR_TRX_PRICE:0:7}  | ${RAW_XMR_TRX_HIGHDAY:0:7}  | ${RAW_XMR_TRX_LOWDAY:0:7}  | ${RAW_XMR_TRX_CHANGEPCTDAY:0:5}%  |" \
		"| Ethereum Classic | ETC  | ${RAW_XMR_ETC_PRICE:0:7}  | ${RAW_XMR_ETC_HIGHDAY:0:7}  | ${RAW_XMR_ETC_LOWDAY:0:7}  | ${RAW_XMR_ETC_CHANGEPCTDAY:0:5}%  |" \
		"| Litecoin         | LTC  | ${RAW_XMR_LTC_PRICE:0:7}  | ${RAW_XMR_LTC_HIGHDAY:0:7}  | ${RAW_XMR_LTC_LOWDAY:0:7}  | ${RAW_XMR_LTC_CHANGEPCTDAY:0:5}%  |" \
		"| Chainlink        | LINK | ${RAW_XMR_LINK_PRICE:0:7} | ${RAW_XMR_LINK_HIGHDAY:0:7} | ${RAW_XMR_LINK_LOWDAY:0:7} | ${RAW_XMR_LINK_CHANGEPCTDAY:0:5}% |" \
		"| Stellar          | XLM  | ${RAW_XMR_XLM_PRICE:0:7}  | ${RAW_XMR_XLM_HIGHDAY:0:7}  | ${RAW_XMR_XLM_LOWDAY:0:7}  | ${RAW_XMR_XLM_CHANGEPCTDAY:0:5}%  |" \
		"| Bitcoin Cash     | BCH  | ${RAW_XMR_BCH_PRICE:0:7}  | ${RAW_XMR_BCH_HIGHDAY:0:7}  | ${RAW_XMR_BCH_LOWDAY:0:7}  | ${RAW_XMR_BCH_CHANGEPCTDAY:0:5}%  |" \
		"| Algorand         | ALGO | ${RAW_XMR_ALGO_PRICE:0:7} | ${RAW_XMR_ALGO_HIGHDAY:0:7} | ${RAW_XMR_ALGO_LOWDAY:0:7} | ${RAW_XMR_ALGO_CHANGEPCTDAY:0:5}% |" \
		"| ZCash            | ZEC  | ${RAW_XMR_ZEC_PRICE:0:7}  | ${RAW_XMR_ZEC_HIGHDAY:0:7}  | ${RAW_XMR_ZEC_LOWDAY:0:7}  | ${RAW_XMR_ZEC_CHANGEPCTDAY:0:5}%  |")
	# Stupid stupid stupid Ubuntu comes with BSD's [column]
	# so [-o] doesn't work. This doesn't even make sense,
	# Ubuntu is mostly GNU/util-linux userspace but for certain
	# programs it has the BSD versions? I thought this was maybe
	# inherited from Debian but even Debian has [util-linux's] version.
	# Why why why why why Ubuntu.

	# Instead of specifically testing for [x] distro,
	# just test to see if the [column -o] option works.
	if echo "Why Ubuntu" | column -o -t &>/dev/null; then
		printf "${BRED}%s${OFF}\n" "[XMR <-> Fiat] <$RAW_XMR_USD_LASTUPDATE>"
		printf "%s\n" "|-----------------------------------------------------------------------------|"
		echo -e "$FIAT"   | column -t -s '|' -o '|'
		printf "%s\n" "|-----------------------------------------------------------------------------|"
		echo
		printf "${BRED}%s${OFF}\n" "[XMR <-> Cryptocurrency] <$RAW_XMR_BTC_LASTUPDATE>"
		printf "%s\n" "|---------------------------------------------------------------------------|"
		echo -e "$CRYPTO" | column -t -s '|' -o '|'
		printf "%s\n" "|---------------------------------------------------------------------------|"
	else
		printf "${BRED}%s${OFF}\n" "[XMR <-> Fiat] <$RAW_XMR_USD_LASTUPDATE>"
		echo -e "$FIAT"   | column -t -s '|'
		echo
		printf "${BRED}%s${OFF}\n" "[XMR <-> Cryptocurrency] <$RAW_XMR_BTC_LASTUPDATE>"
		echo -e "$CRYPTO" | column -t -s '|'
	fi
}
