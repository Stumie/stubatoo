#!/usr/bin/env bash

# Usage: $SUBSCRIPT/wine-prefix-download-software-followlink.sh $WINEPREFIXFOLDER $WINEPREFIXNAME $DOWNLOADLINK $DOWNLOADFILENAME

### Variable declarations ###

THISSCRIPTPATH=$(readlink -f $0)
THISDIRPATH=$(dirname $THISSCRIPTPATH)
SUBSCRIPT=$THISDIRPATH

WINEPREFIXFOLDER=$1
WINEPREFIXNAME=$2
DOWNLOADLINK=$3
DOWNLOADFILENAME=$4
DOWNLOADFOLDER=$WINEPREFIXFOLDER/tmp-downloads/$WINEPREFIXNAME
FULLDOWNLOADFILEPATH=$DOWNLOADFOLDER/$DOWNLOADFILENAME

### Procedures ###

$SUBSCRIPT/check-for-software-existence.sh wget

$SUBSCRIPT/highlighted-output.sh "The script will now download the file from URL '$DOWNLOADLINK' for wine prefix '$WINEPREFIXNAME'."

mkdir -p $DOWNLOADFOLDER
wget --trust-server-names -O $FULLDOWNLOADFILEPATH $DOWNLOADLINK