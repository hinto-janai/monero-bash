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
#            info.sh
#            download.sh
#            verify.sh
#            hook.sh
#            extract.sh
#            copy.sh
#
# creates lock file: /tmp/std_lock_monero_bash_upgrade.XXXXXXXXX

pkg::upgrade() {
	log::debug "starting"

	if [[ $1 = install ]]; then
		log::debug "packages getting installed: $UPGRADE_LIST"
	else
		log::debug "packages getting upgraded: $UPGRADE_LIST"
	fi

	# CREATE TMP FILES AND LOCK
	trap '{ pkg::trap::pkg_folders; lock::free monero_bash_upgrade; } &' EXIT
	if lock::alloc monero_bash_upgrade; then
		log::debug "created lock file: ${STD_LOCK_FILE[monero_bash_upgrade]}"
	else
		log::debug "lock file already found: ${STD_LOCK_FILE[monero_bash_upgrade]}"
		print::error "Could not get upgrade lock!"
		print::exit  "Is there another [monero-bash] upgrade running?"
	fi

	# PRINT TITLE
	print::download

	# FETCH PKG INFO
	log::prog "Fetching metadata... "
	pkg::info

	# DOWNLOAD
	pkg::download

	# VERIFY
	print::verify
	pkg::verify

	# PRE HOOKS
	print::hook::pre
	pkg::hook::pre

	# INSTALLING/UPGRADING TITLE
	if [[ $1 = install ]]; then
		print::install
	else
		print::upgrade
	fi

	# EXTRACT
	pkg::extract

	# TRAP COPY POST HOOKS
	trap '{ pkg::copy &>/dev/null; pkg::hooks::post &>/dev/null; pkg::trap::pkg_folders; lock::free monero_bash_upgrade; } &' EXIT

	# COPY NEW PACKAGES INTO NEW
	pkg::copy

	# POST HOOKS
	print::hook::post
	pkg::hook::post

	# FREE LOCK
	log::debug "freeing lock file: ${STD_LOCK_FILE[monero_bash_upgrade]}"
	lock::free monero_bash_upgrade

	# END
	if [[ $1 = install ]]; then
		print::installed
	else
		print::upgraded
	fi
	trap - EXIT
	log::debug "pkg::upgrade() done"
	exit 0
}
