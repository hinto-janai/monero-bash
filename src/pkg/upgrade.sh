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

# meta function that upgrades packages
# called by: pkg::prompt()
#
# uses:      trap.sh
#            tmp.sh
#            download.sh
#            verify.sh
pkg::upgrade() {
	log::debug "starting ${FUNCNAME}()"
	if [[ $UPGRADE_LIST ]]; then
		log::debug "packages getting upgraded: $UPGRADE_LIST"
	elif [[ $INSTALL_LIST ]]; then
		log::debug "packages getting installed: $UPGRADE_LIST"
	fi

	# CREATE TMP FILES AND LOCK
	trap '{ pkg::trap::pkg_folders; lock::free monero_bash_upgrade; } &' EXIT
	if ! lock::alloc monero_bash_upgrade; then
		print::error "Could not get upgrade lock!"
		print::exit  "Is there another [monero-bash] upgrade running?"
	fi

	# PRINT TITLE
	print::download

	# FETCH PKG INFO
	printf "${BWHITE}%s${OFF}\n" "Fetching metadata... "
	pkg::info

	# DOWNLOAD
	pkg::download

	# VERIFY
	print::verify
	pkg::verify

	# INSTALLING/UPGRADING TITLE
	if [[ $UPGRADE_LIST ]]; then
		print::upgrade
	elif [[ $INSTALL_LIST ]]; then
		print::install
	fi

	# EXTRACT
	pkg::extract

	# -> folder for old pkg
	# -> install for monero-bash
	# -> install for rest
	# -> post-hook for p2pool files
	# -> systemd hook
	# -> state update
}












