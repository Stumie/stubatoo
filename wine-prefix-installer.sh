#!/usr/bin/env bash

### Constant declarations ###

WINESTABLEBRANCH="stable"
WINESTAGINGBRANCH="staging"
WINEDEVELBRANCH="devel"
WINEPREFIXFOLDER="$HOME/.wine-prefix"

### Root protection ###

if [ "$(id -u)" = "0" ]; then
  printf '%s\n' "ERROR! This script must not be run as root!" >&2
  exit 1
fi

### Function declarations ###

# Declare function to show usage of this script
show-usage () {
  $SUBSCRIPT/highlighted-output.sh \
    "Usage: $0 $WINESTABLEBRANCH|$WINESTAGINGBRANCH|$WINEDEVELBRANCH wine-prefix-order" \ \
    "List of all available wine-prefix-orders:" \ \
    "$(basename -s .sh -a $(ls -1 $WINEPREFIXORDERS/*))"
}

wine-branch-validity-check () {
  if [ "$1" != "$WINESTABLEBRANCH" ] && [ "$1" != "$WINESTAGINGBRANCH" ] && [ "$1" != "$WINEDEVELBRANCH" ]; then
    printf '%s\n' "ERROR! Provide valid wine branch statement within script parameters!" >&2
    show-usage
    exit 1
  fi
}

wine-prefix-order-validity-check () {
  wineprefixordertocheck=$1
  wineprefixordervalid=false
  for i in $(basename -s .sh -a $(ls -ldv $WINEPREFIXORDERS/* | awk '{ print $9 }')); do
    if [[ "$i" = "$wineprefixordertocheck" ]]; then
      wineprefixordervalid=true
    fi
  done
  if [[ "$wineprefixordervalid" = false ]]; then
    printf '%s\n' "ERROR! Provide valid wine-prefix-order within script parameters!" >&2
    show-usage
    exit 1
  fi
}

### Variable declarations ###

THISSCRIPTPATH=$(readlink -f $0)
THISDIRPATH=$(dirname $THISSCRIPTPATH)
SUBSCRIPT=$THISDIRPATH/.scripts

WINEPREFIXORDERS=$THISDIRPATH/.wine-prefix-orders
WINEBRANCHNAME=$1
REQUESTEDWINEPREFIXORDER=$2

### Procedures ###

source $SUBSCRIPT/parameter-count-check.sh

parameter-count-check $# 2

wine-branch-validity-check $1

wine-prefix-order-validity-check $REQUESTEDWINEPREFIXORDER

$SUBSCRIPT/inst-reqs.sh wine $WINEBRANCHNAME || { printf '%s\n' "ERROR! Could not install requirements!" >&2 && exit 1; }

$WINEPREFIXORDERS/$REQUESTEDWINEPREFIXORDER.sh $WINEPREFIXFOLDER