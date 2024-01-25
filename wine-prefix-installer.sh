#!/usr/bin/env bash

### Constant declarations ###

WINESTABLEBRANCH="stable"
WINESTAGINGBRANCH="staging"
WINEDEVELBRANCH="devel"
WINEPREFIXFOLDER="$HOME/.wine-prefix"

### Function declarations ###

# Declare function to show usage of this script
show-usage () {
  $SUBSCRIPT/highlighted-output.sh \
    "Usage: $0 $WINESTABLEBRANCH|$WINESTAGINGBRANCH|$WINEDEVELBRANCH|bottles wine-prefix-order" \ \
    "List of all available wine-prefix-orders:" \ \
    "$(basename -s .sh -a $(ls -1v $WINEPREFIXORDERS/*))"
}

wine-branch-validity-check () {
  if [ "$1" != "$WINESTABLEBRANCH" ] && [ "$1" != "$WINESTAGINGBRANCH" ] && [ "$1" != "$WINEDEVELBRANCH" ] && [ "$1" != "bottles" ]; then
    printf '%s\n' "ERROR! Provide valid wine branch statement within script parameters!" >&2
    show-usage
    return 1
  fi
}

wine-prefix-order-validity-check () {
  wineprefixordertocheck=$1
  wineprefixordervalid=false
  for i in $(basename -s .sh -a $(ls -1v $WINEPREFIXORDERS/*)); do
    if [[ "$i" = "$wineprefixordertocheck" ]]; then
      wineprefixordervalid=true
    fi
  done
  if [[ "$wineprefixordervalid" = false ]]; then
    printf '%s\n' "ERROR! Provide valid wine-prefix-order within script parameters!" >&2
    return 1
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
source $SUBSCRIPT/root-protection.sh

root-protection || { show-usage && exit 1; }
parameter-count-check $# 2 || { show-usage && exit 1; }
wine-branch-validity-check $1 || { show-usage && exit 1; }
wine-prefix-order-validity-check $REQUESTEDWINEPREFIXORDER || { show-usage && exit 1; }

$SUBSCRIPT/inst-reqs.sh wine $WINEBRANCHNAME || { printf '%s\n' "ERROR! Could not install requirements!" >&2 && exit 1; }

if [ "$WINEBRANCHNAME" = "bottles" ]; then
  WINEPREFIXFOLDER="$(flatpak run --command=bottles-cli com.usebottles.bottles info bottles-path)" # Overwrite WINEPREFIXFOLDER constant when bottles shall be used
fi

$WINEPREFIXORDERS/$REQUESTEDWINEPREFIXORDER.sh $WINEBRANCHNAME $WINEPREFIXFOLDER