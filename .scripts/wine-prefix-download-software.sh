#!/usr/bin/env bash

# Usage: $SUBSCRIPT/wine-prefix-download-software.sh $WINEPREFIXFOLDER $WINEPREFIXNAME $DOWNLOADLINK

### Variable declarations ###

THISSCRIPTPATH=$(readlink -f $0)
THISDIRPATH=$(dirname $THISSCRIPTPATH)
SUBSCRIPT=$THISDIRPATH

WINEPREFIXFOLDER=$1
WINEPREFIXNAME=$2
DOWNLOADLINK=$3
DOWNLOADFOLDER=$WINEPREFIXFOLDER/tmp-downloads/$WINEPREFIXNAME

### Procedures ###

$SUBSCRIPT/check-for-software-existence.sh wget

$SUBSCRIPT/highlighted-output.sh "The script will now download the file from URL '$DOWNLOADLINK' for wine prefix '$WINEPREFIXNAME'."

mkdir -p $DOWNLOADFOLDER
wget -nc -P $DOWNLOADFOLDER $DOWNLOADLINK