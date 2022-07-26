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

# End-Of-Life
# -----------
# [monero-bash] major versions will (usually) include
# major changes that are not backwards compatible.
# This message is printed if the current [monero-bash]
# version is found to be a major version behind.
#
# CURRENT MAJOR VERSION: V2
print::eol() {
	printf "${BRED}%s${OFF}\n"\
		"" \
	    "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"\
	    "@ This version of [monero-bash] is no @"\
	    "@ longer supported ($MONERO_BASH_VER).          @"\
	    "@ Every major version change, e.g:    @"\
	    "@ v2.0.0 > v3.0.0 contains changes    @"\
	    "@ that break backwards compatability. @"\
	    "@                                     @"\
	    "@ You are free to continue to use     @"\
	    "@ this version, but be aware you will @"\
	    "@ not be able to upgrade monero-bash  @"\
	    "@ and may face bugs in the future.    @"\
	    "@                                     @"\
	    "@ Please move your .bitmonero, wallet @"\
	    "@ and config folders outside of the   @"\
	    "@ [.monero-bash] folder and then      @"\
	    "@ uninstall this monero-bash with:    @"\
	    "@ \"monero-bash uninstall\"             @"\
	    "@ then, you can reinstall the         @"\
	    "@ latest version from:                @@@@@@@@@@"\
	    "@ https://github.com/hinto-janaiyo/monero-bash @"\
	    "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
}
