#!/usr/bin/env bash
#
# update all git submodules.

set -ex
trap 'printf "\e[1;91m%s\e[0m%s\n" "[ERROR CAUGHT] " "$BASH_COMMAND"' ERR

# CHECK PATH
[[ $PWD = */utils ]] && cd ..
[[ $PWD = */monero-bash ]]

# UPDATE
git submodule update --remote
