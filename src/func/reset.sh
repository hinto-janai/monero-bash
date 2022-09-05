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
# Copyright (c) ????-2022, Tamas Szerb <toma@rulez.org>
# Copyright (c) 2008-2022, Robert Hogan <robert@roberthogan.net>
# Copyright (c) 2008-2022, David Goulet <dgoulet@ev0ke.net>
# Copyright (c) 2008-2022, Alex Xu (Hello71) <alex_y_xu@yahoo.ca>

# for overwriting current (old) configs with new ones from "$installDirectory/config"
# and old systemd services with new ones

reset_Config()
{
	case $NAME_PRETTY in
		Monero) RESET_FILE="monerod.conf & monero-wallet-cli.conf";;
		monero-bash) RESET_FILE=monero-bash.conf;;
		XMRig) RESET_FILE=xmrig.json;;
		P2Pool) RESET_FILE=p2pool.conf;;
	esac

	# PROMPT
	BRED; printf "This will overwrite your current "
	BWHITE; echo -n "[$RESET_FILE] "
	BRED; echo "with a new default version"
	BWHITE; printf "Continue? (y/N) " ;OFF
	Yes(){ echo "Resetting..." ;}
	No(){ echo "Exiting..." ;exit 1;}
	prompt_NOyes

	trap "" 1 2 3 6 15
	# OVERWRITE
	case $NAME_PRETTY in
		Monero)
			echo "Resetting [$config/monerod.conf]..."
			cp -f "$installDirectory/config/monerod.conf" "$config/monerod.conf"
			echo "Resetting [$config/monero-wallet-cli.conf]..."
			cp -f "$installDirectory/config/monero-wallet-cli.conf" "$config/monero-wallet-cli.conf"
			;;
		monero-bash)
			echo "Resetting [$config/monero-bash.conf]..."
			cp -f "$installDirectory/config/monero-bash.conf" "$config/monero-bash.conf"
			;;
		XMRig)
			echo "Resetting [$xmrigConf]..."
			cp -f "$installDirectory/config/xmrig.json" "$xmrigConf"
			;;
		P2Pool)
			echo "Resetting [$config/p2pool.conf]..."
			cp -f "$installDirectory/config/p2pool.conf" "$config/p2pool.conf"
			;;
	esac
	BGREEN; echo "Reset OK"; OFF
}

reset_Systemd()
{
	# PROMPT
	BRED; printf "This will overwrite your current "
	BWHITE; echo -n "[$NAME_PRETTY] "
	BRED; echo "systemd service with a new default version"
	BWHITE; printf "Continue? (y/N) " ;OFF
	Yes(){ echo "Resetting..." ;}
	No(){ echo "Exiting..." ;exit 1;}
	prompt_NOyes

	trap "" 1 2 3 6 15
	if systemd_${NAME_FUNC}; then
		BGREEN; echo "Reset OK"; OFF
	else
		BRED; echo "Reset FAIL"; OFF
		return 1
	fi
}
