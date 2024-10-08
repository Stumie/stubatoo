#!/usr/bin/env bash

# Usage: $SUBSCRIPT/press-any-key-helper.sh

### Procedures ###

read -n 1 -s -r -p "Press any key to continue, or Ctrl+C to abort"
printf '\n'