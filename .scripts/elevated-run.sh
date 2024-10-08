#!/usr/bin/env bash

# Usage: $SUBSCRIPT/elevated-run.sh "$EXECUTABLE"

### Variable declarations ###

THISSCRIPTPATH=$(readlink -f $0)
THISDIRPATH=$(dirname $THISSCRIPTPATH)
SUBSCRIPT=$THISDIRPATH

### Procedures ###

source $SUBSCRIPT/obtain-password.sh

$SUBSCRIPT/check-for-software-existence.sh sudo || exit 1

obtain-password

for j in "$*"; do
  echo $password | sudo -S $j
done

unset password