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

#
#						Colors
#
# regular
black="printf \e[0;30m"
red="printf \e[0;31m"
green="printf \e[0;32m"
yellow="printf \e[0;33m"
blue="printf \e[0;34m"
purple="printf \e[0;35m"
cyan="printf \e[0;36m"
white="printf \e[0;37m"
# bold
bblack="printf \e[1;90m"
bred="printf \e[1;91m"
bgreen="printf \e[1;92m"
byellow="printf \e[1;93m"
bblue="printf \e[1;94m"
bpurple="printf \e[1;95m"
bcyan="printf \e[1;96m"
bwhite="printf \e[1;97m"
# underscore
ublack="printf \e[4;30m"
ured="printf \e[4;31m"
ugreen="printf \e[4;32m"
uyellow="printf \e[4;33m"
ublue="printf \e[4;34m"
upurple="printf \e[4;35m"
ucyan="printf \e[4;36m"
uwhite="printf \e[4;37m"
# high intensity
iblack="printf \e[0;90m"
ired="printf \e[0;91m"
igreen="printf \e[0;92m"
iyellow="printf \e[0;93m"
iblue="printf \e[0;94m"
ipurple="printf \e[0;95m"
icyan="printf \e[0;96m"
iwhite="printf \e[0;97m"
# no color
off="printf \e[0m"
