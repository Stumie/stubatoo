#!/usr/bin/env bash

# Usage within script: 
# source $SUBSCRIPT/root-protection.sh
# root-protection || { exit 1; }
# ...

### Function declarations ###

root-protection () {
  if [ "$(id -u)" = "0" ]; then
    printf '%s\n' "ERROR! This script must not be run as root!" >&2
    return 1
  fi
}