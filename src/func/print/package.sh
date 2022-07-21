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

# collection of titles to print during
# package installation/upgrade/removal
# assumes struct::pkg() has been called
print::download() {
	printf "${BGREEN}%s\n" "#---------# Downloading [${PKG[pretty]}] #---------#"
}

print::remove() {
	printf "${BRED}%s\n" "#---------# Removing [${PKG[pretty]}] #---------#"
}

print::verify() {
	printf "${BYELLOW}%s\n" "#---# Verifying [${PKG[pretty]}] #---#"
}

print::extract() {
	printf "${BRED}%s\n" "#---# Extracting [${PKG[pretty]}] #---#"
}

print::state() {
	printf "${BBLUE}%s\n" "#---# Updating local state #---#"
}

print::installed() {
	printf "${BGREEN}%s\n" "#---------# Installed [${PKG[pretty]}] #---------#"
}

print::upgraded() {
	printf "${BGREEN}%s\n" "#---------# Upgraded [${PKG[pretty]}] #---------#"
}

print::removed() {
	printf "${BRED}%s\n" "#---------# Removed [${PKG[pretty]}] #---------#"
}
