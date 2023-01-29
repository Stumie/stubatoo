#!/usr/bin/env bash

### Variable declarations ###

THISSCRIPTPATH=$(readlink -f $0)
THISDIRPATH=$(dirname $THISSCRIPTPATH)
SUBSCRIPT=$THISDIRPATH

### Procedures ###

source $SUBSCRIPT/optain-password.sh

$SUBSCRIPT/check-for-software-existence.sh sudo

optain-password

for j in "$*"; do
  echo $password | sudo -S $j
done

unset password