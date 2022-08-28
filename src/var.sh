# This file is part of monero-bash - a wrapper for Monero, written in Bash
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

#
#                       Global Variables
#
# file/folder paths
usrLocalShare="/usr/local/share"
dotMoneroBash="$HOME/.monero-bash"
config="$dotMoneroBash/config"
wallets="$dotMoneroBash/wallets"
bitMonero="$HOME/.bitmonero"
old="$installDirectory/old"
bin="$installDirectory/bin"
binMonero="$bin/monero"
binXMRig="$bin/xmrig"
binP2Pool="$bin/p2pool"
hashlist="$installDirectory/src/txt/hashlist"
state="$installDirectory/src/txt/state"
sysd="/etc/systemd/system"
xmrigConf="$config/xmrig.json"
p2poolConf="$config/p2pool.conf"
p2poolApi="$binP2Pool/local/stats"
MB_API="$installDirectory/src/api"

#
#						Colors
#
# regular
BLACK() { printf "\e[0;30m"; }
RED() { printf "\e[0;31m"; }
GREEN() { printf "\e[0;32m"; }
YELLOW() { printf "\e[0;33m"; }
BLUE() { printf "\e[0;34m"; }
PURPLE() { printf "\e[0;35m"; }
CYAN() { printf "\e[0;36m"; }
WHITE() { printf "\e[0;37m"; }
# BOLD
BBLACK() { printf "\e[1;90m"; }
BRED() { printf "\e[1;91m"; }
BGREEN() { printf "\e[1;92m"; }
BYELLOW() { printf "\e[1;93m"; }
BBLUE() { printf "\e[1;94m"; }
BPURPLE() { printf "\e[1;95m"; }
BCYAN() { printf "\e[1;96m"; }
BWHITE() { printf "\e[1;97m"; }
# UNDERSCORE
UBLACK() { printf "\e[4;30m"; }
URED() { printf "\e[4;31m"; }
UGREEN() { printf "\e[4;32m"; }
UYELLOW() { printf "\e[4;33m"; }
UBLUE() { printf "\e[4;34m"; }
UPURPLE() { printf "\e[4;35m"; }
UCYAN() { printf "\e[4;36m"; }
UWHITE() { printf "\e[4;37m"; }
# HIGH INTENSITY
IBLACK() { printf "\e[0;90m"; }
IRED() { printf "\e[0;91m"; }
IGREEN() { printf "\e[0;92m"; }
IYELLOW() { printf "\e[0;93m"; }
IBLUE() { printf "\e[0;94m"; }
IPURPLE() { printf "\e[0;95m"; }
ICYAN() { printf "\e[0;96m"; }
IWHITE() { printf "\e[0;97m"; }
# NO COLOR
OFF() { printf "\e[0m"; }

readonly BLACK="\e[0;30m" RED="\e[0;31m" GREEN="\e[0;32m" YELLOW="\e[0;33m" BLUE="\e[0;34m" PURPLE="\e[0;35m" CYAN="\e[0;36m" WHITE="\e[0;37m" BBLACK="\e[1;90m" BRED="\e[1;91m" BGREEN="\e[1;92m" BYELLOW="\e[1;93m" BBLUE="\e[1;94m" BPURPLE="\e[1;95m" BCYAN="\e[1;96m" BWHITE="\e[1;97m" UBLACK="\e[4;30m" URED="\e[4;31m" UGREEN="\e[4;32m" UYELLOW="\e[4;33m" UBLUE="\e[4;34m" UPURPLE="\e[4;35m" UCYAN="\e[4;36m" UWHITE="\e[4;37m" IBLACK="\e[0;90m" IRED="\e[0;91m" IGREEN="\e[0;92m" IYELLOW="\e[0;93m" IBLUE="\e[0;94m" IPURPLE="\e[0;95m" ICYAN="\e[0;96m" IWHITE="\e[0;97m" BOLD="\e[1m" ITALIC="\e[3m" OFF="\e[0m"
