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

# changelog title
print::changelog::title() {
	local CHANGELOG_TITLE CHANGELOG_RELEASE_DATE || return 1
	CHANGELOG_VERSION="$1"
	CHANGELOG_RELEASE_DATE="$2"
	printf "${BCYAN}%s\n" \
		"#==============================#" \
		"# monero-bash $CHANGELOG_VERSION changelog #" \
		"#==============================#" \
		"# RELEASE DATE | $CHANGELOG_RELEASE_DATE" \
		""
}

# print the current monero-bash changelog
print::changelog() {
	print::changelog::2.0.0
}

# print previous monero-bash changelogs
print::changelog::2.0.0() {
	print::changelog::title "v2.0.0"
}

print::changelog::1.6.0() {
	print::changelog::title "v1.6.0" "July 2, 2022"

	printf "${BCYAN}%s\n" \
		"# Updates"

	printf "  ${BOLD}${BWHITE}%s\n" \
		"v1 END OF LIFE"
	printf "    ${OFF}%s\n" \
		"- monero-bash v2.0.0 in progress, a rewrite to make the code safer, faster, and easier to debug" \
		"- Major version upgrades (v1.X.X > v2.X.X) will include changes that break backwards compatability" \
		"- v1.X.X versions will still function, but you will not be able to upgrade monero-bash past v1.9.9" \
		""

	printf "${BCYAN}%s\n" \
		"# Fixes"

	printf "  ${BOLD}${BWHITE}%s\n    ${OFF}%s\n" \
		"systemd" "- Service file permission fix (700 > 600)" \
		"P2Pool"  "- Fetch PGP key from GitHub" \
		"Misc"    "- Fix text coloring issues"
}
