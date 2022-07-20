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

#include <stdlib/src/ask.sh>
#include <stdlib/src/color.sh>
#include <stdlib/src/crypto.sh>
#include <stdlib/src/date.sh>
#include <stdlib/src/debug.sh>
#include <stdlib/src/is.sh>
#include <stdlib/src/lock.sh>
#include <stdlib/src/log.sh>
#include <stdlib/src/panic.sh>
#include <stdlib/src/readonly.sh>
#include <stdlib/src/safety.sh>
#include <stdlib/src/trace.sh>
#include <stdlib/src/type.sh>

main() {
#----------------------------------------- main() START
log::debug "main() started, log::debug initialization"

#----------------------------------------- DEBUG
[[ $1 = DEBUG ]] && DEBUG "$@"

#----------------------------------------- SAFETY
log::debug "starting safety checks"
# check for gnu/linux
safety::gnu_linux
# check for bash v5+
safety::bash
# check for root
safety::root
# check for pipe
safety::pipe

#----------------------------------------- FIRST TIME INSTALLATION
if [[ $FIRST_TIME = true ]]; then
	log::debug "first time detected, starting installation"
	monero_bash::install
else
	log::debug "first time = false, skipping installation"
fi

#----------------------------------------- MORE SAFETY
# check for path
safety::path

#----------------------------------------- PARSE USER INPUT
___BEGIN___ERROR___TRACE___
log::debug "starting parse"
parse::state
parse::config
[[ $# != 0 ]] && parse::options
___ENDOF___ERROR___TRACE___

#----------------------------------------- WALLET
print::title


}
main "$@"
