#!/usr/bin/env bash

# Usage: $SUBSCRIPT/highlighted-output.sh "TEXT"

### Constant declarations ###

dashline="------------------------------------------------------"

### Procedures ###

printf '%s\n' $dashline
for i in "$@"; do
  printf '%s\n' "$i"
done
printf '%s\n' $dashline