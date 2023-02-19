#!/usr/bin/env bash

### Variable declarations ###

THISSCRIPTPATH=$(readlink -f $0)
THISDIRPATH=$(dirname $THISSCRIPTPATH)
SUBSCRIPT=$THISDIRPATH

ACTION=$1
FULLWINEPREFIXPATH=$2

### Procedures ###

$SUBSCRIPT/check-for-software-existence.sh dos2unix || exit 1 # Verfiy existence of dos2unix, even if requirements should been fulfilled before.

if [[ "$ACTION" = "prepare" ]]; then
  WINEPREFIX=$FULLWINEPREFIXPATH wine regedit /E $FULLWINEPREFIXPATH/drive_c/tmp-regedit-export.reg "HKEY_CURRENT_USER\Software\Wine\Debug"
  dos2unix -o $FULLWINEPREFIXPATH/drive_c/tmp-regedit-export.reg
  cat $FULLWINEPREFIXPATH/drive_c/tmp-regedit-export.reg | head -2 > $FULLWINEPREFIXPATH/drive_c/tmp-regedit-import.reg
  rm $FULLWINEPREFIXPATH/drive_c/tmp-regedit-export.reg
fi

if [[ "$ACTION" = "import" ]]; then
  unix2dos -o $FULLWINEPREFIXPATH/drive_c/tmp-regedit-import.reg
  WINEPREFIX=$FULLWINEPREFIXPATH wine regedit $FULLWINEPREFIXPATH/drive_c/tmp-regedit-import.reg
  rm $FULLWINEPREFIXPATH/drive_c/tmp-regedit-import.reg
fi