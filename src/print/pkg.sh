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
print::pkg::download() {
	printf "${BCYAN}%s${OFF}\n" "#---------------------------------------# Downloading"
}

print::pkg::update() {
	printf "${BBLUE}%s${OFF}\n" "#---------------------------------------# Updating"
}

print::pkg::remove() {
	printf "${BRED}%s${OFF}\n" "#---------------------------------------# Removing [${PKG[pretty]}]"
}

print::pkg::verify() {
	printf "${BYELLOW}%s${OFF}\n" "#---------------------------------------# Verifying"
}

print::pkg::install() {
	printf "${BRED}%s${OFF}\n" "#---------------------------------------# Installing"
}

print::pkg::upgrade() {
	printf "${BRED}%s${OFF}\n" "#---------------------------------------# Upgrading"
}

print::pkg::hook::pre() {
	printf "${BPURPLE}%s${OFF}\n" "#---------------------------------------# Pre-Hooks"
}

print::pkg::hook::post() {
	printf "${BPURPLE}%s${OFF}\n" "#---------------------------------------# Post-Hooks"
}

print::pkg::installed() {
	printf "${BGREEN}%s${OFF}\n" "#---------------------------------------# Install done"
}

print::pkg::upgraded() {
	printf "${BGREEN}%s${OFF}\n" "#---------------------------------------# Upgrade done"
}

print::pkg::upgrade_fail() {
	printf "${BRED}%s${OFF}\n" "#---------------------------------------# Upgrade failed"
}

print::pkg::removed() {
	printf "${BRED}%s${OFF}\n" "#---------------------------------------# Removed [${PKG[pretty]}]"
}

print::pkg::updated() {
	printf "${BCYAN}%s${OFF}\n" "#---------------------------------------# All packages up-to-date"
}
