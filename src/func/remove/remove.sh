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

# remove packages
# called from remove::prompt()
# assumes ask::sudo() was called
remove() {
	log::debug "starting removal of: ${PKG[name]}"

	___BEGIN___ERROR___TRACE___
	trap "" INT
	print::remove

	# REMOVE PKG DIRECTORY
	log::prog "${PKG[directory]}..."
	rm "${PKG[directory]}"
	log::ok "${PKG[directory]} deleted"

	# REMOVE SYSTEMD SERVICE
	log::prog "${PKG[service]}..."
	sudo rm "$SYSTEMD/${PKG[service]}"
	log::ok "${PKG[service]} deleted"

	# UPDATE LOCAL STATE
	log::prog "Updating local state..."
	sudo sed \
		-i -e "s/${PKG[var]}_VER=./${PKG[var]}_VER=/" "$STATE" \
		-i -e "s/${PKG[var]}_OLD=./${PKG[var]}_OLD=\"true\"/" "$STATE"
	log::ok "Updated local state"

	# RELOAD SYSTEMD
	log::prog "Reloading systemd..."
	systemd::reload
	log::ok "Reloaded systemd"

	# END
	print::removed
	___ENDOF___ERROR___TRACE___
}

