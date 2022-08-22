# libjson.sh
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
# Parts of this library are orignally:
# Copyright (c) 2011-2022, Dominic Tarr

#git <libjson/libjson.sh/29d1cf2>

# Parse JSON with Bash + Grep/AWK
# Input must be piped in, no args.
# Taken from: https://github.com/dominictarr/JSON.sh
# and modified slightly to work as a function and to
# use more widely adopted UNIX tool versions, Debian
# need these changes: gawk -> awk, egrep -> grep -E
json::sh() {
	json::throw() {
	  echo "$*" >&2
	  return 1
	}

	BRIEF=0
	LEAFONLY=0
	PRUNE=0
	NO_HEAD=0
	NORMALIZE_SOLIDUS=0

	json::usage() {
	  echo
	  echo "Usage: JSON.sh [-b] [-l] [-p] [-s] [-h]"
	  echo
	  echo "-p - Prune empty. Exclude fields with empty values."
	  echo "-l - Leaf only. Only show leaf nodes, which stops data duplication."
	  echo "-b - Brief. Combines 'Leaf only' and 'Prune empty' options."
	  echo "-n - No-head. Do not show nodes that have no path (lines that start with [])."
	  echo "-s - Remove escaping of the solidus symbol (straight slash)."
	  echo "-h - This help text."
	  echo
	}

	json::parse_options() {
	  set -- "$@"
	  local ARGN=$#
	  while [ "$ARGN" -ne 0 ]
	  do
	    case $1 in
	      -h) json::usage
	          return 0
	      ;;
	      -b) BRIEF=1
	          LEAFONLY=1
	          PRUNE=1
	      ;;
	      -l) LEAFONLY=1
	      ;;
	      -p) PRUNE=1
	      ;;
	      -n) NO_HEAD=1
	      ;;
	      -s) NORMALIZE_SOLIDUS=1
	      ;;
	      ?*) echo "ERROR: Unknown option."
	          json::usage
	          return 0
	      ;;
	    esac
	    shift 1
	    ARGN=$((ARGN-1))
	  done
	}

	json::awk_egrep() {
	  local pattern_string=$1

	  awk '{
	    while ($0) {
	      start=match($0, pattern);
	      token=substr($0, start, RLENGTH);
	      print token;
	      $0=substr($0, start+RLENGTH);
	    }
	  }' pattern="$pattern_string"
	}

	json::tokenize() {
	  local ESCAPE
	  local CHAR

	  if echo "test string" | grep -E -ao --color=never "test" >/dev/null 2>&1
	  then
	    json::grep() { grep -E -ao --color=never "$@"; }
	  else
	    json::grep() { grep -E -ao "$@"; }
	  fi

	  if echo "test string" | grep -E -o "test" >/dev/null 2>&1
	  then
	    ESCAPE='(\\[^u[:cntrl:]]|\\u[0-9a-fA-F]{4})'
	    CHAR='[^[:cntrl:]"\\]'
	  else
	    json::grep() { json::awk_egrep "$@"; }
	    ESCAPE='(\\\\[^u[:cntrl:]]|\\u[0-9a-fA-F]{4})'
	    CHAR='[^[:cntrl:]"\\\\]'
	  fi

	  local STRING="\"$CHAR*($ESCAPE$CHAR*)*\""
	  local NUMBER='-?(0|[1-9][0-9]*)([.][0-9]*)?([eE][+-]?[0-9]*)?'
	  local KEYWORD='null|false|true'
	  local SPACE='[[:space:]]+'

	  # Force zsh to expand $A into multiple words
	  local is_wordsplit_disabled=$(unsetopt 2>/dev/null | grep -c '^shwordsplit$')
	  if [ $is_wordsplit_disabled != 0 ]; then setopt shwordsplit; fi
	  json::grep "$STRING|$NUMBER|$KEYWORD|$SPACE|." | grep -E -v "^$SPACE$"
	  if [ $is_wordsplit_disabled != 0 ]; then unsetopt shwordsplit; fi
	}

	json::parse_array() {
	  local index=0
	  local ary=''
	  read -r token
	  case "$token" in
	    ']') ;;
	    *)
	      while :
	      do
	        json::parse_value "$1" "$index"
	        index=$((index+1))
	        ary="$ary""$value" 
	        read -r token
	        case "$token" in
	          ']') break ;;
	          ',') ary="$ary," ;;
	          *) json::throw "EXPECTED , or ] GOT ${token:-EOF}" ;;
	        esac
	        read -r token
	      done
	      ;;
	  esac
	  [ "$BRIEF" -eq 0 ] && value=$(printf '[%s]' "$ary") || value=
	  :
	}

	json::parse_object() {
	  local key
	  local obj=''
	  read -r token
	  case "$token" in
	    '}') ;;
	    *)
	      while :
	      do
	        case "$token" in
	          '"'*'"') key=$token ;;
	          *) json::throw "EXPECTED string GOT ${token:-EOF}" ;;
	        esac
	        read -r token
	        case "$token" in
	          ':') ;;
	          *) json::throw "EXPECTED : GOT ${token:-EOF}" ;;
	        esac
	        read -r token
	        json::parse_value "$1" "$key"
	        obj="$obj$key:$value"        
	        read -r token
	        case "$token" in
	          '}') break ;;
	          ',') obj="$obj," ;;
	          *) json::throw "EXPECTED , or } GOT ${token:-EOF}" ;;
	        esac
	        read -r token
	      done
	    ;;
	  esac
	  [ "$BRIEF" -eq 0 ] && value=$(printf '{%s}' "$obj") || value=
	  :
	}

	json::parse_value() {
	  local jpath="${1:+$1,}$2" isleaf=0 isempty=0 print=0
	  case "$token" in
	    '{') json::parse_object "$jpath" ;;
	    '[') json::parse_array  "$jpath" ;;
	    # At this point, the only valid single-character tokens are digits.
	    ''|[!0-9]) json::throw "EXPECTED value GOT ${token:-EOF}" ;;
	    *) value=$token
	       # if asked, replace solidus ("\/") in json strings with normalized value: "/"
	       [ "$NORMALIZE_SOLIDUS" -eq 1 ] && value=$(echo "$value" | sed 's#\\/#/#g')
	       isleaf=1
	       [ "$value" = '""' ] && isempty=1
	       ;;
	  esac
	  [ "$value" = '' ] && return
	  [ "$NO_HEAD" -eq 1 ] && [ -z "$jpath" ] && return

	  [ "$LEAFONLY" -eq 0 ] && [ "$PRUNE" -eq 0 ] && print=1
	  [ "$LEAFONLY" -eq 1 ] && [ "$isleaf" -eq 1 ] && [ $PRUNE -eq 0 ] && print=1
	  [ "$LEAFONLY" -eq 0 ] && [ "$PRUNE" -eq 1 ] && [ "$isempty" -eq 0 ] && print=1
	  [ "$LEAFONLY" -eq 1 ] && [ "$isleaf" -eq 1 ] && \
	    [ $PRUNE -eq 1 ] && [ $isempty -eq 0 ] && print=1
	  [ "$print" -eq 1 ] && printf "[%s]\t%s\n" "$jpath" "$value"
	  :
	}

	json::parse() {
	  read -r token
	  json::parse_value
	  read -r token
	  case "$token" in
	    '') ;;
	    *) json::throw "EXPECTED EOF GOT $token" ;;
	  esac
	}

  json::parse_options "$@"
  json::tokenize | json::parse
}

# This function parses json::sh() output and turns it into
# a text list of standard Shell variable declaration, e.g:
# JSON:
# -----
# {
#   "id": "0",
#   "jsonrpc": "2.0",
#   "result": {
#     "block_header": {
#       "block_size": 80,
#
# json::sh() output:
# ------------------
# ["id"]	"0"
# ["jsonrpc"]	"2.0"
# ["result","block_header","block_size"]	80
#
# json::var() output:
# -------------------
# id=0
# jsonrpc=2.0
# result_block_header_block_size=80
#
# This is now in a form where
# Bash can easily source it.
json::var() { json::sh -l | sed "s/\[\"//g; s/\"\]\t\"/=/g; s/\"$//g; s/\"\]\t/=/g; s/\",\"/_/g; s/={/='{/g; s/}$/}'/g"; }

# This skips printing to STDOUT and
# directly sources the variables created
# from above. This create GLOBAL variables.
json::src() { source <(json::var); }
