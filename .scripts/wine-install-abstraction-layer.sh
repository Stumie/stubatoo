#!/usr/bin/env bash

### Variable declarations ###

WINEPREFIXNAME=$(basename -s .sh $0)
WINEBRANCHNAME=$1
WINEPREFIXFOLDER=$2
FULLWINEPREFIXPATH=$WINEPREFIXFOLDER/$WINEPREFIXNAME

### Function declarations ###

source $SUBSCRIPT/wine-install-winetricks-verbs.sh

wine-prepare () {
  if [ "$WINEBRANCHNAME" != "bottles" ]; then
    $SUBSCRIPT/wine-prefix-prepare-first-run.sh $WINEARCH $WINEPREFIXFOLDER $WINEPREFIXNAME || { printf '%s\n' "ERROR! Could not prepare wine prefix!" >&2 && exit 1; }
  else
    WINEPREFIXFOLDER="$(flatpak run --command=bottles-cli com.usebottles.bottles info bottles-path)" # Overwrite WINEPREFIXFOLDER constant when bottles shall be used
    FULLWINEPREFIXPATH=$WINEPREFIXFOLDER/$WINEPREFIXNAME # Overwrite FULLWINEPREFIXPATH since WINEPREFIXFOLDER changed
    if [[ -d "$FULLWINEPREFIXPATH" ]]; then
      echo "ERROR! The bottle \"$WINEPREFIXNAME\" allready exists. Delete bottle via Bottles first!"
      exit 1
    fi
    $SUBSCRIPT/highlighted-output.sh "The script will now ask: Which wine runner available in Bottles should be used?"
    $SUBSCRIPT/press-any-key-helper.sh
    RUNNER=$(flatpak run --command=bottles-cli com.usebottles.bottles list components -f category:runners  | grep - | awk '{print $2}' | fzf --phony --no-multi --layout=reverse --header="Which wine runner available in Bottles should be used?" | xargs printf "%q\n")
    if [ "$RUNNER" = "" ]; then
      echo "No wine runner chosen or available within Bottles. Please open Bottles and add one first."
      exit 1
    fi
    WINEBINARIESPATH="$(realpath $WINEPREFIXFOLDER/../runners/$RUNNER/bin)"
    flatpak run --command=bottles-cli com.usebottles.bottles new --bottle-name $WINEPREFIXNAME --arch $WINEARCH --runner $RUNNER --environment custom
  fi
}

wine-set-winver () {
  winver="$1"
  if [ "$WINEBRANCHNAME" != "bottles" ]; then
    install-winetricks-verbs "$winver"
  else
    # flatpak run --command=bottles-cli com.usebottles.bottles edit --bottle $WINEPREFIXNAME --win $winver # Commented out since it often freezes but generally is a better way
    flatpak run --command=bottles-cli com.usebottles.bottles shell --bottle $WINEPREFIXNAME --input "winecfg -v $winver"
  fi
}

wine-install-prerequisites () {
  if [ "$WINEBRANCHNAME" != "bottles" ]; then
    install-winetricks-verbs "$@"  
  else
    WINE=$WINEBINARIESPATH/wine WINESERVER=$WINEBINARIESPATH/wineserver WINEPREFIX=$FULLWINEPREFIXPATH WINEARCH=$WINEARCH winetricks --unattended "$@" # Install dependencies via winetricks since bottles-cli does not offer an interface for it (2024-01-23)
  fi
}

wine-reboot () {
  if [ "$WINEBRANCHNAME" != "bottles" ]; then
    WINEPREFIX=$FULLWINEPREFIXPATH WINEARCH=$WINEARCH wineboot -u
    WINEPREFIX=$FULLWINEPREFIXPATH WINEARCH=$WINEARCH wineboot -r
  else
    WINEPREFIX=$FULLWINEPREFIXPATH WINEARCH=$WINEARCH $WINEBINARIESPATH/wineboot -u
    WINEPREFIX=$FULLWINEPREFIXPATH WINEARCH=$WINEARCH $WINEBINARIESPATH/wineboot -r
  fi
}

wine-execute () {
  if [ "$WINEBRANCHNAME" != "bottles" ]; then
    WINEPREFIX=$FULLWINEPREFIXPATH WINEARCH=$WINEARCH wine "$@"
  else
    flatpak run --command='bottles-cli' com.usebottles.bottles run --bottle $WINEPREFIXNAME --executable "$@"
  fi
}

wine-reg-add () {
  key="$1"
  value="$2"
  type="$3"
  data="$4"
  if [ "$WINEBRANCHNAME" != "bottles" ]; then
    WINEPREFIX=$FULLWINEPREFIXPATH WINEARCH=$WINEARCH wine reg add "$key" /v "$value" /t "$type" /d "$data" /f  
  else
    flatpak run --command=bottles-cli com.usebottles.bottles reg --bottle $WINEPREFIXNAME --key "$key" --value "$value" --data "$data" --key-type "$type" add
  fi
}

download () {
  downloadlink="$1"
  $SUBSCRIPT/wine-prefix-download-software.sh $WINEPREFIXFOLDER $WINEPREFIXNAME $downloadlink || { printf '%s\n' "ERROR! Could not download file!" >&2 && exit 1; }
}

download-followlink () {
  downloadlink="$1"
  filename="$2"
  $SUBSCRIPT/wine-prefix-download-software-followlink.sh $WINEPREFIXFOLDER $WINEPREFIXNAME $downloadlink $filename  || { printf '%s\n' "ERROR! Could not download file!" >&2 && exit 1; }
}