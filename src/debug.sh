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

# debugging tools for monero-bash
# USE VERY CAREFULLY

# invoke a monero-bash function directly
DEBUG_04e3be9()
{
	BRED; echo "@@@@@@   DEBUG MODE - BE CAREFUL   @@@@@@"
	IWHITE; echo -n "function to execute: " ;OFF
	read command
	"$command"
}

# list all monero-bash functions, variables
LIST()
{
	echo -e "\033[1;32mMONERO-BASH GLOBAL FUNCTIONS:\033[0m"
	declare -F | sed 's/declare -f //g'
	echo -e "\033[1;33mMONERO-BASH GLOBAL VARIABLES:\033[0m"
	cat "src/var.sh" | grep -v "#" | grep -v "\033"
}

# produce a hash list for important monero-bash files /monero-bash/src/txt/hashlist
PRODUCE_HASH_LIST_TEMPLATE()
{
	for i in $DIR/* ;do
		if [[ -f "$i" && "$i" != "src/txt/hashlist" ]]; then
			sudo sha256sum $i >> "$hashlist"
		fi
	done
}
PRODUCE_HASH_LIST()
{
	prompt_Sudo
	echo "Producing hashlist..."
	sudo echo -n > "$hashlist"
	sudo sha256sum "monero-bash" >> "$hashlist"
	local DIR="src"
	PRODUCE_HASH_LIST_TEMPLATE
	local DIR="src/func"
	PRODUCE_HASH_LIST_TEMPLATE
	local DIR="src/txt"
	PRODUCE_HASH_LIST_TEMPLATE
	local DIR="config"
	PRODUCE_HASH_LIST_TEMPLATE
	local DIR="gpg"
	PRODUCE_HASH_LIST_TEMPLATE
}

# check hash list against current monero-bash files (with color coded output)
CHECK_HASH_LIST_TEMPLATE()
{
	for i in $DIR/* ;do
		if [[ -f "$i" && "$i" != "src/txt/hashlist" ]]; then
			grep "$i" "$hashlist" | sha256sum -c &>/dev/null
			if [[ $? = "0" ]]; then
				BGREEN; printf "[  OK  ] "
				WHITE; echo "$i"
			else
				BRED; printf "[FAILED] "
				WHITE; echo "$i"
				hashFail="true"
			fi
		fi
	done
}
CHECK_HASH_LIST()
{
	# monero-bash hash
	grep "monero-bash" "$hashlist" | sha256sum -c &>/dev/null
	if [[ $? = "0" ]]; then
		BGREEN; printf "[  OK  ] "
		WHITE; echo "monero-bash"
	else
		BRED; printf "[FAILED] "
		WHITE; echo "monero-bash"
		hashFail="true"
	fi

	# the rest
	local DIR="src"
	CHECK_HASH_LIST_TEMPLATE
	local DIR="src/func"
	CHECK_HASH_LIST_TEMPLATE
	local DIR="src/txt"
	CHECK_HASH_LIST_TEMPLATE
	local DIR="src/config"
	CHECK_HASH_LIST_TEMPLATE
	local DIR="gpg"
	CHECK_HASH_LIST_TEMPLATE

	if [[ $hashFail = "true" ]]; then
		BRED; echo -n "monero-bash error: "
		BWHITE; echo "hash check has failed"
		WHITE; echo "Exiting for safety..."
		exit 1
	else
		BWHITE; echo -n "[monero-bash] "
		BGREEN; echo "HASH CHECK OK!" ;OFF
	fi
}

# checks the hash list less verbosely
QUIET_HASH_LIST_TEMPLATE()
{
	for i in $DIR/* ;do
		if [[ -f "$i" && "$i" != "src/txt/hashlist" ]]; then
			grep "$i" "$hashlist" | sha256sum -c &>/dev/null
			[[ $? != "0" ]]&& hashFail="true" && local localHashFail="true"
		fi
	done
	if [[ $localHashFail = "true" ]]; then
		BRED; printf "[FAILED] "
		WHITE; echo "$NAME"
	else
		BGREEN; printf "[  OK  ] "
		WHITE; echo "$NAME"
	fi
}
QUIET_HASH_LIST()
{
	# monero-bash hash
	grep "monero-bash" "$hashlist" | sha256sum -c &>/dev/null
	if [[ $? = "0" ]]; then
		BGREEN; printf "[  OK  ] "
		WHITE; echo "monero-bash"
	else
		BRED; printf "[FAILED] "
		WHITE; echo "monero-bash"
		hashFail="true"
	fi

	# the rest
	local NAME="src"
	local DIR="src"
	QUIET_HASH_LIST_TEMPLATE
	local NAME="func"
	local DIR="src/func"
	QUIET_HASH_LIST_TEMPLATE
	local NAME="txt"
	local DIR="src/txt"
	QUIET_HASH_LIST_TEMPLATE
	local NAME="config"
	local DIR="config"
	QUIET_HASH_LIST_TEMPLATE
	local NAME="gpg"
	local DIR="gpg"
	QUIET_HASH_LIST_TEMPLATE

	if [[ $hashFail = "true" ]]; then
		BRED; echo -n "[monero-bash error] "
		BWHITE; echo "hash check has failed"
		WHITE; echo "Exiting for safety..."
		exit 1
	else
		BWHITE; echo -n "[monero-bash] "
		BGREEN; echo "HASH CHECK OK!" ;OFF
	fi
}
