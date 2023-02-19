#!/usr/bin/env bash

### Variable declarations ###

THISSCRIPTPATH=$(readlink -f $0)
THISDIRPATH=$(dirname $THISSCRIPTPATH)
SUBSCRIPT=$THISDIRPATH/.scripts
SUBTREES=$THISDIRPATH/.subtrees

### Function declarations ###

get-connections () {
  source $SUBTREES/awk_netstat/awk_netstat.sh
}

### Procedures ###

$SUBSCRIPT/check-for-software-existence.sh awk column || exit 1

get-connections | column -t