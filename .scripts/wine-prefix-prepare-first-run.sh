#!/usr/bin/env bash

# Usage: $SUBSCRIPT/wine-prefix-prepare-first-run.sh $WINEARCH $WINEPREFIXFOLDER $WINEPREFIXNAME

### Variable declarations ###

THISSCRIPTPATH=$(readlink -f $0)
THISDIRPATH=$(dirname $THISSCRIPTPATH)
SUBSCRIPT=$THISDIRPATH

WINEARCH=$1
WINEPREFIXFOLDER=$2
WINEPREFIXNAME=$3
FULLWINEPREFIXPATH=$WINEPREFIXFOLDER/$WINEPREFIXNAME

### Procedures ###

# Kill and remove existing prefix with the same name
$SUBSCRIPT/highlighted-output.sh \
  "The script will now kill and remove any existing wine-prefix with the name '$WINEPREFIXNAME', if necessary." \
  "Install Mono and Gecko, if any windows ask for it."
if [ -d "$FULLWINEPREFIXPATH" ]; then
  WINEPREFIX=$FULLWINEPREFIXPATH WINEARCH=$WINEARCH wineboot --force --kill
  WINEPREFIX=$FULLWINEPREFIXPATH WINEARCH=$WINEARCH winetricks --unattended --force annihilate
  rm -rfv $FULLWINEPREFIXPATH
fi

# Create the wine prefix and do a "first boot"
$SUBSCRIPT/highlighted-output.sh \
  "The script will now prepare the wine environment for the wine-prefix with the name '$WINEPREFIXNAME'." \
  "Install Mono and Gecko, if any windows ask for it."
mkdir -p $FULLWINEPREFIXPATH
WINEPREFIX=$FULLWINEPREFIXPATH WINEARCH=$WINEARCH wineboot -i