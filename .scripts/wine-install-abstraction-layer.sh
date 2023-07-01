#!/usr/bin/env bash

### Variable declarations ###

WINEPREFIXNAME=$(basename -s .sh $0)
WINEPREFIXFOLDER=$1
FULLWINEPREFIXPATH=$WINEPREFIXFOLDER/$WINEPREFIXNAME

### Function declarations ###

source $SUBSCRIPT/wine-install-winetricks-verbs.sh

wine-prepare () {
  $SUBSCRIPT/wine-prefix-prepare-first-run.sh $WINEARCH $WINEPREFIXFOLDER $WINEPREFIXNAME || { printf '%s\n' "ERROR! Could not prepare wine prefix!" >&2 && exit 1; }
}

wine-set-winver () {
  winver=$1
  install-winetricks-verbs $winver
}

wine-install-prerequisites () {
  install-winetricks-verbs $@
}

wine-update-and-reboot () {
  WINEPREFIX=$FULLWINEPREFIXPATH WINEARCH=$WINEARCH wineboot -u
  WINEPREFIX=$FULLWINEPREFIXPATH WINEARCH=$WINEARCH wineboot -r
}

wine-execute () {
  WINEPREFIX=$FULLWINEPREFIXPATH WINEARCH=$WINEARCH wine $@
}

wine-reg-add () {
  key=$1
  value=$2
  type=$3
  data=$4
  WINEPREFIX=$FULLWINEPREFIXPATH WINEARCH=$WINEARCH wine reg add "$key" /v "$value" /t "$type" /d "$data" /f
}

download () {
  downloadlink=$1
  $SUBSCRIPT/wine-prefix-download-software.sh $WINEPREFIXFOLDER $WINEPREFIXNAME $downloadlink || { printf '%s\n' "ERROR! Could not download file!" >&2 && exit 1; }
}

download-followlink () {
  downloadlink=$1
  filename=$2
  $SUBSCRIPT/wine-prefix-download-software-followlink.sh $WINEPREFIXFOLDER $WINEPREFIXNAME $downloadlink $filename  || { printf '%s\n' "ERROR! Could not download file!" >&2 && exit 1; }
}