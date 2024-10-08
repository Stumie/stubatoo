#!/usr/bin/env bash

# Usage: $SUBSCRIPT/check-for-software-existence.sh package

### Procedures ###

for i in $@
do
  if ! command -v $i &> /dev/null; then
    printf '%s\n' "ERROR! The software package '$i' is necessary, but could not be found, exiting."
    if command -v apt-get &> /dev/null; then
      printf '%s\n' "You might want to try something like 'sudo apt-get update && sudo apt-get install $i' to install it."
    fi
    exit 1
  fi
done