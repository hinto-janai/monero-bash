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


# Safety checks so monero-bash doesn't blow something up

# checks if /.monero-bash/ exists, if not, build default
safety_DotMoneroBash()
{
    if [[ ! -d "$dotMoneroBash" ]]; then
        print_Warn "[${HOME}/.monero-bash/] folder not found!"
		echo "Building default [.monero-bash] folder..."
		build_DotMoneroBash
		OFF; echo "Built!"
    fi
}

# check if in /usr/local/share/monero-bash
safety_UsrLocalShare()
{
	if [[ "$installDirectory" != "/usr/local/share/monero-bash" ]]; then
		IRED; echo "ERROR: monero-bash not in /usr/local/share/ !"
		OFF; echo "was monero-bash installed properly?"
		echo "Exiting for safety..."
		exit 1
	fi
}

# checks quiet_hashlist only if not previously checked (used in download)
safety_HashList()
{
	if [[ $alreadyCheckedHashList != "true" ]]; then
		QUIET_HASH_LIST
		alreadyCheckedHashList="true"
		echo
	fi
}

safety_Root()
{
	if [[ "$EUID" = 0 ]]; then
		printf "\033[1;31m[MONERO-BASH ERROR] "
		printf "\033[1;37mDO NOT RUN AS ROOT\n"
		exit 1
	fi
}

# monero-bash only supports 1 user
safety_User()
{
	if [[ "$INSTALLED_USER" != "$USER" ]]; then
		printf "\033[1;31m[monero-bash error] "
		printf "\033[0mOnly this user is allowed: "
		printf "\033[1;37m$INSTALLED_USER\n"
		exit 1
	fi
}

# check for GNU/Linux
safety::gnu_linux() {
	if [[ $OSTYPE != *linux-gnu* ]]; then
		printf "\033[1;31m%s\033[0m%s\n%s\n" \
		"[monero-bash error] " \
		"GNU/Linux not detected!" \
		"Exiting for safety..."
		exit 1
	fi
}


# check for bash v5+
safety::bash() {
	if [[ ! ${BASH_VERSINFO[0]} -ge 5 ]]; then
		printf "\033[1;31m%s\033[0m%s\n%s\n" \
			"[monero-bash error] " \
			"Your Bash is older than v5." \
			"Exiting for safety..."
		exit 1
	fi
}

# check for x86_64bit
# only invoked during the initial [monero-bash] install
safety::x86_64() {
	[[ $(uname -m) = x86_64 ]] || print_Error_Exit "Non-x86_64 computer detected, refusing to continue"
}

# check for sane environment
# variables and set as readonly.
safety::env() {
    # $HOME
    case "$HOME" in
        "/home/$USER") :;;
        *) print_Error_Exit "Dangerous \$HOME variable detected, refusing to start";;
    esac
    # $USER
    case "$USER" in
        "${HOME/\/home\/}") :;;
        *) print_Error_Exit "Dangerous \$USER variable detected, refusing to start";;
    esac
    # $PATH
    case "$PATH" in
        */usr/bin*) :;;
        */bin*) :;;
        *) print_Error_Exit "Dangerous \$PATH variable detected, refusing to start";;
    esac
	# Path isn't declared as READONLY because
	# it needs to be edited when using Tor
	# (getcap is in /usr/sbin which isn't in PATH for Debian)
	#
	# USER also gets edited to root for XMRig, so no readonly
    declare -gxr HOME
}
