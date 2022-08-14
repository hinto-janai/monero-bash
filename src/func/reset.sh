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

# for overwriting current (old) configs with new ones from "$installDirectory/config"
# and old systemd services with new ones

reset_Template()
{
	# PROMPT
	if [[ $NAME_PRETTY = "monero-bash" ]]; then
		$bred; printf "This will overwrite your current "
		$bwhite; echo -n "[${NAME_PRETTY}] "
		$bred; echo "config with a new default version"
	else
		$bred; printf "This will overwrite your current "
		$bwhite; echo -n "[${NAME_PRETTY}] "
		$bred; echo "configs & systemd services with a new default version"
	fi
	$bwhite; printf "Continue? (y/N) " ;$off
	Yes(){ echo "Resetting..." ;}
	No(){ echo "Exiting..." ;exit;}
	prompt_NOyes

	# SAFETY
	prompt_Sudo;error_Sudo
	safety_HashList
	trap "" 1 2 3 6 15
	[[ "$NAME_VER" = "" ]]&& echo "$NAME_PRETTY isn't installed" && exit

	# OVERWRITE
	case $NAME_PRETTY in
		Monero)
			echo "Resetting [$config/monerod.conf]..."
			sudo -u "$USER" cp -f "$installDirectory/config/monerod.conf" "$config/monerod.conf"
			echo "Resetting [$config/monero-wallet-cli.conf]..."
			sudo -u "$USER" cp -f "$installDirectory/config/monero-wallet-cli.conf" "$config/monero-wallet-cli.conf"
			systemd_"$NAME_FUNC"
			;;
		monero-bash)
			echo "Resetting [$config/monero-bash.conf]..."
			sudo -u "$USER" cp -f "$installDirectory/config/monero-bash.conf" "$config/monero-bash.conf"
			;;
		XMRig)
			echo "Resetting [$xmrigConf]..."
			sudo -u "$USER" cp -f "$installDirectory/config/xmrig.json" "$xmrigConf"
			systemd_"$NAME_FUNC"
			sudo -u "$USER" sed -i "s@.*MINE_UNCONFIGURED.*@MINE_UNCONFIGURED=\"true\"@" "$state"
			PRODUCE_HASH_LIST
			;;
		P2Pool)
			echo "Resetting [$p2poolConf]..."
			sudo -u "$USER" cp -f "$installDirectory/config/p2pool.json" "$p2poolConf"
			systemd_"$NAME_FUNC"
			sudo -u "$USER" sed -i "s@.*MINE_UNCONFIGURED.*@MINE_UNCONFIGURED=\"true\"@" "$state"
			PRODUCE_HASH_LIST
			;;
	esac
	$bgreen; echo "Reset complete"; $off
}
