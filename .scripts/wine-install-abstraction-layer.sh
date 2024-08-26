#!/usr/bin/env bash

### Constant declarations ###

WINESTABLEBRANCH="stable"
WINESTAGINGBRANCH="staging"
WINEDEVELBRANCH="devel"

### Variable declarations ###

WINEPREFIXNAME=$(basename -s .sh $0)
WINEBRANCHNAME=$1
WINEPREFIXFOLDER=$2
FULLWINEPREFIXPATH=$WINEPREFIXFOLDER/$WINEPREFIXNAME

### Function declarations ###

source $SUBSCRIPT/wine-install-winetricks-verbs.sh

download () {
  downloadlink="$1"
  $SUBSCRIPT/wine-prefix-download-software.sh $WINEPREFIXFOLDER $WINEPREFIXNAME $downloadlink || { printf '%s\n' "ERROR! Could not download file!" >&2 && exit 1; }
}

download-followlink () {
  downloadlink="$1"
  filename="$2"
  $SUBSCRIPT/wine-prefix-download-software-followlink.sh $WINEPREFIXFOLDER $WINEPREFIXNAME $downloadlink $filename  || { printf '%s\n' "ERROR! Could not download file!" >&2 && exit 1; }
}

wine-prepare () {
  if [[ "$WINEBRANCHNAME" = "bottles-noreqs" ]]; then
    # Workaround to get winetricks without requirement installation
    if ! command -v winetricks &> /dev/null; then
      $SUBSCRIPT/check-for-software-existence.sh curl || exit 1
      mkdir -p $HOME/.local/bin/
      curl -L -z $HOME/.local/bin/winetricks "https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks" -o $HOME/.local/bin/winetricks
      chmod +x $HOME/.local/bin/winetricks
      [[ " ${PATH//:/ } " =~ " $HOME/.local/bin " ]] || export PATH="$HOME/.local/bin${PATH:+:${PATH}}"
    fi
  fi
  if [[ "$WINEBRANCHNAME" = "bottles" ]] || [[ "$WINEBRANCHNAME" = "bottles-noreqs" ]]; then
    $SUBSCRIPT/check-for-software-existence.sh flatpak fzf || exit 1
    flatpak override --user --filesystem=$HOME com.usebottles.bottles  # Allow flatpak access to home directory for Bottles
    WINEPREFIXFOLDER="$(flatpak run --command=bottles-cli com.usebottles.bottles info bottles-path)" # Hack: Overwrite WINEPREFIXFOLDER constant when bottles shall be used
    FULLWINEPREFIXPATH=$WINEPREFIXFOLDER/$WINEPREFIXNAME # Hack: Overwrite FULLWINEPREFIXPATH since WINEPREFIXFOLDER changed
    if [[ -d "$FULLWINEPREFIXPATH" ]]; then
      echo "ERROR! The bottle \"$WINEPREFIXNAME\" allready exists. Delete bottle via Bottles first!"
      exit 1
    fi
    $SUBSCRIPT/highlighted-output.sh "The script will now ask: Which wine runner available in Bottles should be used?"
    $SUBSCRIPT/press-any-key-helper.sh
    RUNNER=$(flatpak run --command=bottles-cli com.usebottles.bottles list components -f category:runners  | grep - | awk '{print $2}' | grep -v sys-wine | fzf --phony --no-multi --layout=reverse --header="Which wine runner available in Bottles should be used?" | xargs printf "%q\n")
    if [ "$RUNNER" = "" ]; then
      echo "No wine runner chosen or available within Bottles. Please open Bottles and add one first."
      exit 1
    fi
    WINEBINARIESPATH="$(realpath $WINEPREFIXFOLDER/../runners/$RUNNER/bin)"
    flatpak run --command=bottles-cli com.usebottles.bottles new --bottle-name $WINEPREFIXNAME --arch $WINEARCH --runner $RUNNER --environment custom
  fi
  if ! [ "$WINEBRANCHNAME" != "$WINESTABLEBRANCH" ] && [ "$WINEBRANCHNAME" != "$WINESTAGINGBRANCH" ] && [ "$WINEBRANCHNAME" != "$WINEDEVELBRANCH" ]; then
    $SUBSCRIPT/wine-prefix-prepare-first-run.sh $WINEARCH $WINEPREFIXFOLDER $WINEPREFIXNAME || { printf '%s\n' "ERROR! Could not prepare wine prefix!" >&2 && exit 1; }
  fi
}

wine-set-winver () {
  winver="$1"
  if [[ "$WINEBRANCHNAME" = "bottles" ]] || [[ "$WINEBRANCHNAME" = "bottles-noreqs" ]]; then
    flatpak run --command=bottles-cli com.usebottles.bottles edit --bottle $WINEPREFIXNAME --win $winver # sometimes freezes, comment out then
    flatpak run --command=bottles-cli com.usebottles.bottles shell --bottle $WINEPREFIXNAME --input "winecfg -v $winver" # because the former command often does not work
    $SUBSCRIPT/highlighted-output.sh "The script did set the windows version of your bottle to \"$winver\". Though, for the bottles path of this script this can be inconsistent. You better re-set the windows version within the Bottles GUI."
  fi
  if ! [ "$WINEBRANCHNAME" != "$WINESTABLEBRANCH" ] && [ "$WINEBRANCHNAME" != "$WINESTAGINGBRANCH" ] && [ "$WINEBRANCHNAME" != "$WINEDEVELBRANCH" ]; then
    install-winetricks-verbs "$winver"
  fi
}

wine-install-prerequisites () {
  $SUBSCRIPT/check-for-software-existence.sh winetricks || exit 1
  if [[ "$WINEBRANCHNAME" = "bottles" ]] || [[ "$WINEBRANCHNAME" = "bottles-noreqs" ]]; then
    flatpak run --env=WINE=$WINEBINARIESPATH/wine --env=WINESERVER=$WINEBINARIESPATH/wineserver --env=WINEPREFIX=$FULLWINEPREFIXPATH --env=WINEARCH=$WINEARCH --command=$(command -v winetricks) com.usebottles.bottles --unattended "$@" # Install dependencies via winetricks since bottles-cli does not offer an interface for it (2024-01-23)
  fi
  if ! [ "$WINEBRANCHNAME" != "$WINESTABLEBRANCH" ] && [ "$WINEBRANCHNAME" != "$WINESTAGINGBRANCH" ] && [ "$WINEBRANCHNAME" != "$WINEDEVELBRANCH" ]; then
    install-winetricks-verbs "$@"  
  fi
}

wine-reboot () {
  if [[ "$WINEBRANCHNAME" = "bottles" ]] || [[ "$WINEBRANCHNAME" = "bottles-noreqs" ]]; then
    flatpak run --env=WINE=$WINEBINARIESPATH/wine --env=WINESERVER=$WINEBINARIESPATH/wineserver --env=WINEPREFIX=$FULLWINEPREFIXPATH --env=WINEARCH=$WINEARCH --command=$WINEBINARIESPATH/wineboot com.usebottles.bottles -u
    flatpak run --env=WINE=$WINEBINARIESPATH/wine --env=WINESERVER=$WINEBINARIESPATH/wineserver --env=WINEPREFIX=$FULLWINEPREFIXPATH --env=WINEARCH=$WINEARCH --command=$WINEBINARIESPATH/wineboot com.usebottles.bottles -r
  fi
  if ! [ "$WINEBRANCHNAME" != "$WINESTABLEBRANCH" ] && [ "$WINEBRANCHNAME" != "$WINESTAGINGBRANCH" ] && [ "$WINEBRANCHNAME" != "$WINEDEVELBRANCH" ]; then
    WINEPREFIX=$FULLWINEPREFIXPATH WINEARCH=$WINEARCH wineboot -u
    WINEPREFIX=$FULLWINEPREFIXPATH WINEARCH=$WINEARCH wineboot -r
  fi
}

wine-execute () {
  if [[ "$WINEBRANCHNAME" = "bottles" ]] || [[ "$WINEBRANCHNAME" = "bottles-noreqs" ]]; then
    flatpak run --command='bottles-cli' com.usebottles.bottles run --bottle $WINEPREFIXNAME --executable "$@"
  fi
  if ! [ "$WINEBRANCHNAME" != "$WINESTABLEBRANCH" ] && [ "$WINEBRANCHNAME" != "$WINESTAGINGBRANCH" ] && [ "$WINEBRANCHNAME" != "$WINEDEVELBRANCH" ]; then
    WINEPREFIX=$FULLWINEPREFIXPATH WINEARCH=$WINEARCH wine "$@"
  fi
}

wine-reg-add () {
  key="$1"
  value="$2"
  type="$3"
  data="$4"
  if [[ "$WINEBRANCHNAME" = "bottles" ]] || [[ "$WINEBRANCHNAME" = "bottles-noreqs" ]]; then
    flatpak run --command=bottles-cli com.usebottles.bottles reg --bottle $WINEPREFIXNAME --key "$key" --value "$value" --data "$data" --key-type "$type" add
  fi
  if ! [ "$WINEBRANCHNAME" != "$WINESTABLEBRANCH" ] && [ "$WINEBRANCHNAME" != "$WINESTAGINGBRANCH" ] && [ "$WINEBRANCHNAME" != "$WINEDEVELBRANCH" ]; then
    WINEPREFIX=$FULLWINEPREFIXPATH WINEARCH=$WINEARCH wine reg add "$key" /v "$value" /t "$type" /d "$data" /f  
  fi
}

enable-vulkan-renderer () {
  if [[ "$WINEBRANCHNAME" = "bottles" ]] || [[ "$WINEBRANCHNAME" = "bottles-noreqs" ]]; then
    flatpak run --command=bottles-cli com.usebottles.bottles edit --bottle $WINEPREFIXNAME --params renderer:vulkan
  fi
  if ! [ "$WINEBRANCHNAME" != "$WINESTABLEBRANCH" ] && [ "$WINEBRANCHNAME" != "$WINESTAGINGBRANCH" ] && [ "$WINEBRANCHNAME" != "$WINEDEVELBRANCH" ]; then
    install-winetricks-verbs "renderer=vulkan"
  fi
}

enable-dxvk () {
  enable-vulkan-renderer
  if [[ "$WINEBRANCHNAME" = "bottles" ]] || [[ "$WINEBRANCHNAME" = "bottles-noreqs" ]]; then
    flatpak run --command=bottles-cli com.usebottles.bottles edit --bottle $WINEPREFIXNAME --params dxvk:true
  fi
  if ! [ "$WINEBRANCHNAME" != "$WINESTABLEBRANCH" ] && [ "$WINEBRANCHNAME" != "$WINESTAGINGBRANCH" ] && [ "$WINEBRANCHNAME" != "$WINEDEVELBRANCH" ]; then
    install-winetricks-verbs "dxvk"
  fi
}