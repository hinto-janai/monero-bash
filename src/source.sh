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

# MASTER SOURCE FILE

# global variables
source "$installDirectory/src/var.sh" 2>/dev/null || varMissing="true"

# global functions
for functions in $installDirectory/src/func/*.sh; do
	source "$functions" 2>/dev/null || funcMissing="true"
done

# debug file
source "$installDirectory/src/debug.sh" 2>/dev/null || debugMissing="true"

# state file
source "$installDirectory/src/txt/state" 2>/dev/null || stateMissing="true"

# hashlist file
if [[ ! -f "$installDirectory/src/txt/hashlist" ]]; then
	hashlistMissing="true"
fi

# monero-bash config
source "$config/monero-bash.conf" 2>/dev/null || configMissing="true"

# p2pool config
source "$config/p2pool.conf" 2>/dev/null || configMissing="true"