#!/usr/bin/env bash
#
# create hashlist for [monero-bash] files.
# sends output to --> txt/hashlist

set -ex
trap 'printf "\e[1;91m%s\e[0m%s\n" "[ERROR CAUGHT] " "$BASH_COMMAND"' ERR

# CHECK PATH
[[ $PWD = */utils ]] && cd ..
[[ $PWD = */monero-bash ]]

# HASHLIST PATH
HASHLIST=txt/hashlist

# FILES
sha256sum monero-bash > $HASHLIST
sha256sum txt/state >> $HASHLIST
sha256sum config/* >> $HASHLIST
sha256sum pgp/* >> $HASHLIST
