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


# order of operations:
# 1. filter $DUMP variable (from "download_Template" function)
# 2. find the proper version number
# 3. save it as $NewVer variable

# invoked by "download_Template" function, reuses the "$DUMP" variable
version_Template()
{
	if [[ "$HTML" = "true" ]]; then
		NewVer="$(echo "$DUMP" \
			| grep -o "/$AUTHOR/$PROJECT/releases/tag/.*\"" \
			| awk '{print $1}' | head -n1 \
			| sed "s@/$AUTHOR/$PROJECT/releases/tag/@@g" | tr -d '"')"
		[[ $NewVer = "" ]]&& error_Exit "GitHub HTML filter failed..."
	else
		NewVer="$(echo "$DUMP" | grep "tag_name" | awk '{print $2}' | tr -d '",')"
	fi
}

# invoked by "monero-bash update"
version_Update()
{
	LINK="$(wget -qO- "https://api.github.com/repos/$AUTHOR/$PROJECT/releases/latest")"
	if [[ $? != "0" && "$HTML" != "true" ]]; then
		IRED; echo "GitHub API error detected..."
		OFF; echo "Trying GitHub HTML filter instead..."
		HTML="true"
	fi
	if [[ "$HTML" = "true" ]]; then
		NewVer="$(wget -qO- https://github.com/$AUTHOR/$PROJECT/releases/latest \
			| grep -o "/$AUTHOR/$PROJECT/releases/tag/.*\"" \
			| awk '{print $1}' | head -n1 \
			| sed "s@/$AUTHOR/$PROJECT/releases/tag/@@g" | tr -d '"')"
		[[ $NewVer = "" ]]&& error_Exit "GitHub HTML filter failed..."
	else
		NewVer="$(echo "$LINK" | grep "tag_name" | awk '{print $2}' | tr -d '",')"
	fi
	# END OF LIFE WARNING
	[[ $PROJECT = monero-bash && $NewVer != v1* ]] && ___END___OF___LIFE___
}

