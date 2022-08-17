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


# watch functions - for watching output of the systemd services created
# by monero-bash, e.g. "monero-bash-xmrig.service"
#
# this function would be much simpler to implement if i could use "screen".
# although that program is GNU, it is not within the coreutils, and also not
# pre-installed on Arch, Debian, Fedora, etc.
#
# and so, this is a (poor man's) version using tools most Linux distros have

watch_Template()
{
	# tput lines = available lines detected terminal
	# divided by 2 to account for line wraps.
	# 1 line that line wraps still counts as 1 line,
	# this makes it so bottom messages won't be seen.
	local LINES=$(($(tput lines) / 2))
	if [[ "$SERVICE" = "monero-bash-xmrig.service" ]]; then
		sudo watch -n 1 -t -c "journalctl -u $SERVICE --output cat | tail -n $LINES"
	else
		watch -n 1 -t -c "journalctl -u $SERVICE --output cat | tail -n $LINES"
	fi
}

# Watch [monero-bash status] at (default) 2-second intervals.
# It's more like 5-second because [monerod --status] take so long to open.
# Thanks for the idea u/austinspringer64
# https://www.reddit.com/r/Monero/comments/wqp62v/comment/ikoijbh/?utm_source=reddit&utm_medium=web2x&context=3
watch_Status() { watch -c 'monero-bash status'; }

watch_Monero()
{
	define_Monero
	watch_Template
}

watch_XMRig()
{
	define_XMRig
	watch_Template
}

watch_P2Pool()
{
	define_P2Pool
	watch_Template
}
