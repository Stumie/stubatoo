#!/usr/bin/env bash

### Constant declarations ###

WINEPREFIXFOLDER="$HOME/.wine-prefix"

### Function declarations ###

# Declare function to show usage of this script
show-usage () {
  $SUBSCRIPT/highlighted-output.sh \
    "Usage: $0 winehq|bottles"
}

### Variable declarations ###

THISSCRIPTPATH=$(readlink -f $0)
THISDIRPATH=$(dirname $THISSCRIPTPATH)
SUBSCRIPT=$THISDIRPATH/.scripts

INSTALLATIONVARIANT=$1

### Procedures ###

source $SUBSCRIPT/parameter-count-check.sh
source $SUBSCRIPT/root-protection.sh

root-protection || { show-usage && exit 1; }
parameter-count-check $# 1 || { show-usage && exit 1; }
$SUBSCRIPT/check-for-software-existence.sh fzf

if [ "$INSTALLATIONVARIANT" = "bottles" ]; then
  $SUBSCRIPT/check-for-software-existence.sh flatpak
  bottle=$(ls -1v $(flatpak run --command=bottles-cli com.usebottles.bottles info bottles-path) \
    | fzf --phony --no-multi --layout=reverse --header="Which bottle do you want to remove cleanly?" \
    | xargs printf "%q\n")
  if [ "$bottle" != "" ]; then
    $SUBSCRIPT/highlighted-output.sh \
      "Do you really want to remove \"$bottle\"?"
    $SUBSCRIPT/press-any-key-helper.sh
    flatpak kill com.usebottles.bottles
    rm -vrf "$(flatpak run --command=bottles-cli com.usebottles.bottles info bottles-path)/$bottle"
  else
    echo "ERROR! No bottle chosen. Did nothing."
    exit 1
  fi
fi

if [ "$INSTALLATIONVARIANT" = "winehq" ]; then
  $SUBSCRIPT/check-for-software-existence.sh winetricks
  wineprefix=$(ls -1v $WINEPREFIXFOLDER | grep -v 'tmp-downloads' \
    | fzf --phony --no-multi --layout=reverse --header="Which bottle do you want to remove cleanly?" \
    | xargs printf "%q\n")
  if [ "$wineprefix" != "" ]; then
    $SUBSCRIPT/highlighted-output.sh \
      "Do you really want to remove \"$wineprefix\"?"
    $SUBSCRIPT/press-any-key-helper.sh
    WINEPREFIX=$WINEPREFIXFOLDER/$wineprefix winetricks --unattended --force annihilate
  else
    echo "ERROR! No wine prefix chosen. Did nothing."
    exit 1
  fi
fi

exit 0