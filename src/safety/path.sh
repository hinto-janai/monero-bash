# This file is part of monero-bash - a wrapper for Monero, written in Bash
#
# Copyright (c) 2022 hinto.janaiyo <https://github.com/hinto-janaiyo>
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

# path sanity checks
safety::path() {
	log::debug "starting"

	if [[ $REAL = "$MAIN" ]]; then
		log::debug "PATH OK: $MAIN"
		return 0
	else
		log::debug "PATH is not in: $MAIN"
		log::debug "REAL: $REAL"
		if [[ $REAL = */monero-bash/monero-bash ]]; then
			log::debug "PATH detected to be in [monero-bash] folder, checking FIRST_TIME"
			if [[ $FIRST_TIME = true ]]; then
				log::debug "FIRST_TIME = true | OK, continuing to install"
				return 0
			else
				print::error "FIRST_TIME = $FIRST_TIME | something is very wrong"
				print::error "monero-bash is in the [monero-bash] folder, yet FIRST_TIME is not true"
				print::error "The state file might be corrupted"
				print::exit  "Exiting for safety..."
			fi
		fi
	fi

	log::debug   "incorrect path detected: $REAL"
	print::error "[monero-bash] is in an unknown PATH"
	print::exit  "Exiting for safety..."
}
