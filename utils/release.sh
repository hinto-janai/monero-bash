#!/usr/bin/env bash
#
# create a new [monero-bash] release
# with the files in the current directory.

# ERROR HANDLING
set -e
trap 'ERR_CODE=$?; printf "\e[1;91m%s\e[0m%s\n" "[ERROR CAUGHT] " "$BASH_COMMAND"; exit $ERR_CODE' ERR

# CHECK PATH
[[ $PWD = */utils ]] && cd ..
[[ $PWD = */monero-bash ]]

# VARIABLES
SRC="$PWD"
source txt/state
VER=$MONERO_BASH_VER
TAR="monero-bash-${VER}.tar"

# CLEAN TMP
[[ -e /tmp/monero-bash ]]   && rm -rf /tmp/monero-bash
[[ -e /tmp/SHA256SUM.asc ]] && rm -rf /tmp/SHA256SUM.ash
[[ -e /tmp/SHA256SUM ]]     && rm -rf /tmp/SHA256SUM
[[ -e /tmp/"$TAR" ]]        && rm -rf /tmp/"$TAR"

# CREATE TMP
mkdir /tmp/monero-bash
cp -fr "$SRC/monero-bash" /tmp/monero-bash
cp -fr "$SRC/LICENSE" /tmp/monero-bash
cp -fr "$SRC/config" /tmp/monero-bash
cp -fr "$SRC/pgp" /tmp/monero-bash
cp -fr "$SRC/txt" /tmp/monero-bash

# CREATE TAR
cd /tmp
tar -cf "$TAR" monero-bash

# CREATE HASH
sha256sum "$TAR" > SHA256SUM

# SIGN HASH
gpg --clearsign SHA256SUM
mv -f SHA256SUM.asc SHA256SUM

# VERIFY HASH
if sha256sum -c SHA256SUM &>/dev/null; then
	printf "\e[1;93m%s\e[1;92m%s\e[0m\n" "[${TAR}] " "HASH OK"
else
	printf "\e[1;93m%s\e[1;91m%s\e[0m\n" "[${TAR}] " "HASH FAIL"
	exit 1
fi

# VERIFY PGP
if gpg --verify SHA256SUM &>/dev/null; then
	printf "\e[1;93m%s\e[1;92m%s\e[0m\n" "[${TAR}] " "PGP  OK"
else
	printf "\e[1;93m%s\e[1;91m%s\e[0m\n" "[${TAR}] " "PGP  FAIL"
	exit 1
fi

# CREATE & COPY CHANGELOG INTO CLIPBOARD
CHANGELOG=$(mktemp /tmp/monero-bash-${VER}-changelog.XXXXXX)
sed -n "/# $VER/,/# v/p" "$SRC/CHANGELOG.md" | head -n -1 > $CHANGELOG
echo "## SHA256SUM & [PGP Signature](https://github.com/hinto-janaiyo/monero-bash/blob/main/gpg/hinto-janaiyo.asc)" >> $CHANGELOG
echo '```' >> $CHANGELOG
cat /tmp/SHA256SUM >> $CHANGELOG
echo '```' >> $CHANGELOG
cat $CHANGELOG | xclip -selection clipboard
printf "\e[1;93m%s\e[1;92m%s\e[0m\n" "[${TAR}] " "CLIP OK"

# END
printf "\e[1;93m%s\e[0m%s\n" "[${TAR}] " "done"
