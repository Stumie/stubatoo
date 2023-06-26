#!/usr/bin/env bash

### Function declarations ###

wine-prepare () {
  # TO BE FILLED
}

wine-set-winver-and-install-prerequisites () {
  # TO BE FILLED
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