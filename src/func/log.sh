# This file is part of stdlib.sh - a standard library for Bash
#
# Copyright (c) 2022 hinto.janaiyo <https://github.com/hinto-janai>
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

#git <stdlib/log.sh/4c8490f>

# log()
# -----
# print formatted
# messages to the terminal.
# the line is first cleared then
# the message is printed. this is to
# avoid previous messages (from log::prog)
# from leaving traces. can take
# multiple inputs, each input will
# be formatted and print a newline.

log::ok() { printf "\r\e[2K\e[1;32m[  OK  ]\e[0m %s\n" "$@"; }
log::info() { printf "\r\e[2K\e[1;37m[ INFO ]\e[0m %s\n" "$@"; }
log::warn() { printf "\r\e[2K\e[1;33m[ WARN ]\e[0m %s\n" "$@"; }
log::fail() { printf "\r\e[2K\e[1;31m[ FAIL ]\e[0m %s\n" "$@"; }
log::danger() { printf "\r\e[2K\e[1;31m[DANGER]\e[0m %s\n" "$@"; }

# format with 8 spaces instead of []
log::tab() { printf "\r\e[2K\e[0m         %s\n" "$@"; }

# do not print a newline, leave cursor at the end.
# printing a different log:: will overwrite this one.
log::prog() { printf "\r\e[2K\e[1;37m[ \e[0m....\e[1;37m ]\e[0m %s " "$@"; }
