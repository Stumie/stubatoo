#!/usr/bin/env bash

### Variable declarations ###

THISSCRIPTPATH=$(readlink -f $0)
THISDIRPATH=$(dirname $THISSCRIPTPATH)
SUBSCRIPT=$THISDIRPATH/../.scripts

WINEPREFIXFOLDER=$1
DOWNLOADFOLDER=$WINEPREFIXFOLDER/tmp-downloads

### Procedures ###

$SUBSCRIPT/highlighted-output.sh \
  "Removing these files and folders:" \
  "$(ls -1 $DOWNLOADFOLDER)"

rm -vrf $DOWNLOADFOLDER/*

$SUBSCRIPT/highlighted-output.sh \
  "$ ls -lA $DOWNLOADFOLDER" \
  "$(ls -lA $DOWNLOADFOLDER)"