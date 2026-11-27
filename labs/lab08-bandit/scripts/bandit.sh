#!/usr/bin/env bash
# bandit.sh - connect to a level of the OverTheWire Bandit wargame by its number.
#
# Usage:  ./bandit.sh LEVEL
#         ./bandit.sh 5      -> ssh -p 2220 bandit5@bandit.labs.overthewire.org
#
# The level number is the only argument. The password is typed at the ssh prompt;
# it is never stored in this script or passed on the command line.

set -euo pipefail

readonly HOST="bandit.labs.overthewire.org"
readonly PORT=2220
readonly MAX_LEVEL=34   # the last Bandit level that exists

usage() {
    echo "Usage: $(basename "$0") LEVEL" >&2
    echo "  LEVEL  a whole number from 0 to ${MAX_LEVEL}, e.g. $(basename "$0") 5" >&2
}

if [[ $# -ne 1 ]]; then
    echo "Error: expected exactly one argument (the level number), got $#." >&2
    usage
    exit 1
fi

level="$1"

if ! [[ "${level}" =~ ^[0-9]+$ ]]; then
    echo "Error: '${level}' is not a level number - use digits only, e.g. 5." >&2
    usage
    exit 2
fi

level=$((10#${level}))   # "05" -> 5; base 10 so a leading zero is not read as octal

if (( level > MAX_LEVEL )); then
    echo "Error: level ${level} does not exist - Bandit has levels 0 to ${MAX_LEVEL}." >&2
    usage
    exit 2
fi

echo "Connecting to bandit${level}@${HOST} on port ${PORT} ..."
exec ssh -p "${PORT}" "bandit${level}@${HOST}"
