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

# Path Functions
# manages path installation, removal, etc.

path_Add()
{
	if [[ -f "/usr/local/bin/monero-bash" ]]; then
		$ired; echo -n "monero-bash PATH is already set: "
		$off; echo "/usr/local/bin/monero-bash"
		path_Reset
	else
		sudo ln -s "$installDirectory/monero-bash" "/usr/local/bin/monero-bash"
		error_Continue "Adding to PATH failed"
	fi
}

path_Remove()
{
	if [[ -f "/usr/local/bin/monero-bash" ]]; then
		sudo rm "/usr/local/bin/monero-bash"
	else
		$ired; echo "monero-bash PATH is not set"
	fi
}

path_Reset()
{
	echo "Resetting monero-bash PATH..."
	sudo rm "/usr/local/bin/monero-bash"
	error_Exit "Removing from PATH failed"
	sudo ln -s "$installDirectory/monero-bash" "/usr/local/bin/monero-bash"
	error_Exit "Adding to PATH failed"
	$igreen; echo "monero-bash PATH reset!"
}
