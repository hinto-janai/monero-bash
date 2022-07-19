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

# print the monero-bash title
print::title() {
	log::debug "seeding title rng"
	local TITLE_RANDOM
	TITLE_RANDOM=$RANDOM
	######################################### 60% probability
	if [[ $TITLE_RANDOM -le 19660 ]]; then
			printf "${BRED}%s${OFF}\n" \
				"###################" \
				"#   monero-bash   #" \
				"###################"
		log::debug "title luck: common 60%"
	######################################### 30% probability
	elif [[ $TITLE_RANDOM -le 29490 ]]; then
			printf "${BBLUE}%s${OFF}\n" \
				"xxxxxxxxxxxxxxxxxxx" \
				"x   monero-bash   x" \
				"xxxxxxxxxxxxxxxxxxx"
		log::debug "title luck: rare 30%"
	######################################### 9% probability
	elif [[ $TITLE_RANDOM -le 32439 ]]; then
			printf "${BPURPLE}%s${OFF}\n" \
				":::::::::::::::::::" \
				":   monero-bash   :" \
				":::::::::::::::::::"
		log::debug "title luck: ultra 9%"
	######################################### 0.99% probability
	elif [[ $TITLE_RANDOM -le 32766 ]]; then
			printf "${BYELLOW}%s${OFF}\n" \
				"///////////////////" \
				"/   monero-bash   /" \
				"///////////////////"
		log::debug "title luck: legendary 0.99%"
	######################################### go buy a lottery ticket - 0.0030519% probability, 1/32767
	else
		printf "${BGREEN}%s${OFF}\n" \
			"###################" \
			"#   monero-bash   #" \
			"###################"
		log::debug "title luck: lottery 0.0030519%"
	fi
}
