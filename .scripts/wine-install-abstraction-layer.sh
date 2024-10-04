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
  if [ "$downloadlink" = "" ]; then printf '%s\n' "ERROR! Could not download file!" >&2 && exit 1; fi
  $SUBSCRIPT/wine-prefix-download-software.sh $WINEPREFIXFOLDER $WINEPREFIXNAME $downloadlink || { printf '%s\n' "ERROR! Could not download file!" >&2 && exit 1; }
}

download-followlink () {
  downloadlink="$1"
  filename="$2"
  if [ "$downloadlink" = "" ] || [ "$filename" = "" ]; then printf '%s\n' "ERROR! Could not download file!" >&2 && exit 1; fi
  $SUBSCRIPT/wine-prefix-download-software-followlink.sh $WINEPREFIXFOLDER $WINEPREFIXNAME $downloadlink $filename  || { printf '%s\n' "ERROR! Could not download file!" >&2 && exit 1; }
}

unpackzip () {
  zipfile="$1"
  targetpath="$2"
  if $SUBSCRIPT/check-for-software-existence.sh unzip &> /dev/null; then
    unzip -o $zipfile -d $targetpath
  elif $SUBSCRIPT/check-for-software-existence.sh 7z &> /dev/null; then
    7z x $zipfile -o$targetpath
  else
    printf '%s\n' "ERROR! Could not extract $zipfile because of missing possibilites!" >&2
    exit 1
  fi
}

wine-prepare () {
  # Workaround to get winetricks without requirement installation
  if [[ "$WINEBRANCHNAME" = "bottles-noreqs" ]]; then
    if ! $SUBSCRIPT/check-for-software-existence.sh winetricks &> /dev/null; then
      $SUBSCRIPT/check-for-software-existence.sh curl || exit 1
      mkdir -p $HOME/.local/bin/
      curl -L -z $HOME/.local/bin/winetricks "https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks" -o $HOME/.local/bin/winetricks
      chmod +x $HOME/.local/bin/winetricks
      [[ " ${PATH//:/ } " =~ " $HOME/.local/bin " ]] || export PATH="$HOME/.local/bin${PATH:+:${PATH}}"
    fi
  fi

  case "$WINEBRANCHNAME" in
    "bottles" | "bottles-noreqs")
      $SUBSCRIPT/check-for-software-existence.sh flatpak jq fzf || exit 1
      flatpak override --user --filesystem=$HOME com.usebottles.bottles  # Allow flatpak access to home directory for Bottles
      WINEPREFIXFOLDER="$(flatpak run --command=bottles-cli com.usebottles.bottles info bottles-path)" # Hack: Overwrite WINEPREFIXFOLDER constant when bottles shall be used
      FULLWINEPREFIXPATH=$WINEPREFIXFOLDER/$WINEPREFIXNAME # Hack: Overwrite FULLWINEPREFIXPATH since WINEPREFIXFOLDER changed
      if [[ -d "$FULLWINEPREFIXPATH" ]]; then
        echo "ERROR! The bottle \"$WINEPREFIXNAME\" allready exists. Delete bottle via Bottles first!"
        exit 1
      fi
      $SUBSCRIPT/highlighted-output.sh "The script will now ask: Which wine runner available in Bottles should be used?"
      $SUBSCRIPT/press-any-key-helper.sh
      RUNNER=$(flatpak run --command=bottles-cli com.usebottles.bottles --json list components -f category:runners | jq -r .runners[] | grep -v sys-wine | fzf --phony --no-multi --layout=reverse --header="Which wine runner available in Bottles should be used?" | xargs printf "%q\n")
      if [ "$RUNNER" = "" ]; then
        echo "No wine runner chosen or available within Bottles. Please open Bottles and add one first."
        exit 1
      fi
      WINEBINARIESPATH="$(realpath $WINEPREFIXFOLDER/../runners/$RUNNER/bin)"
      flatpak run --command=bottles-cli com.usebottles.bottles new --bottle-name $WINEPREFIXNAME --arch $WINEARCH --runner $RUNNER --environment custom
      ;;
    "$WINESTABLEBRANCH" | "$WINESTAGINGBRANCH" | "$WINEDEVELBRANCH")
      $SUBSCRIPT/wine-prefix-prepare-first-run.sh $WINEARCH $WINEPREFIXFOLDER $WINEPREFIXNAME || { printf '%s\n' "ERROR! Could not prepare wine prefix!" >&2 && exit 1; }
      ;;
    *)
      echo "ERROR! Could prepare wine environment for $WINEPREFIXNAME!"
      exit 1
      ;;
  esac
}

wine-set-winver () {
  winver=$1
  case "$WINEBRANCHNAME" in
    "bottles" | "bottles-noreqs")
      flatpak run --command=bottles-cli com.usebottles.bottles edit --bottle $WINEPREFIXNAME --win $winver # sometimes freezes, comment out then
      flatpak run --command=bottles-cli com.usebottles.bottles shell --bottle $WINEPREFIXNAME --input "winecfg -v $winver" # because the former command often does not work
      $SUBSCRIPT/highlighted-output.sh "The script did set the windows version of your bottle to \"$winver\". Though, for the bottles path of this script this can be inconsistent. You better re-set the windows version within the Bottles GUI."
      ;;
    "$WINESTABLEBRANCH" | "$WINESTAGINGBRANCH" | "$WINEDEVELBRANCH")
      install-winetricks-verbs "$winver"
      ;;
    *)
      echo "ERROR! Could not set $WINEPREFIXNAME to $winver!"
      exit 1
      ;;
  esac
}

wine-install-prerequisites () {
  $SUBSCRIPT/check-for-software-existence.sh winetricks || exit 1
  case "$WINEBRANCHNAME" in
    "bottles" | "bottles-noreqs")
      flatpak run --env=WINE=$WINEBINARIESPATH/wine --env=WINESERVER=$WINEBINARIESPATH/wineserver --env=WINEPREFIX=$FULLWINEPREFIXPATH --env=WINEARCH=$WINEARCH --command=$(command -v winetricks) com.usebottles.bottles --unattended "$@" # Install dependencies via winetricks since bottles-cli does not offer an interface for it (2024-01-23)
      ;;
    "$WINESTABLEBRANCH" | "$WINESTAGINGBRANCH" | "$WINEDEVELBRANCH")
      install-winetricks-verbs "$@"
      ;;
    *)
      echo "ERROR! Could not install prerequisites to $WINEPREFIXNAME!"
      exit 1
      ;;
  esac
}

wine-reboot () {
  case "$WINEBRANCHNAME" in
    "bottles" | "bottles-noreqs")
      flatpak run --env=WINE=$WINEBINARIESPATH/wine --env=WINESERVER=$WINEBINARIESPATH/wineserver --env=WINEPREFIX=$FULLWINEPREFIXPATH --env=WINEARCH=$WINEARCH --command=$WINEBINARIESPATH/wineboot com.usebottles.bottles -u
      flatpak run --env=WINE=$WINEBINARIESPATH/wine --env=WINESERVER=$WINEBINARIESPATH/wineserver --env=WINEPREFIX=$FULLWINEPREFIXPATH --env=WINEARCH=$WINEARCH --command=$WINEBINARIESPATH/wineboot com.usebottles.bottles -r
      ;;
    "$WINESTABLEBRANCH" | "$WINESTAGINGBRANCH" | "$WINEDEVELBRANCH")
      WINEPREFIX=$FULLWINEPREFIXPATH WINEARCH=$WINEARCH wineboot -u
      WINEPREFIX=$FULLWINEPREFIXPATH WINEARCH=$WINEARCH wineboot -r
      ;;
    *)
      echo "ERROR! Could not reboot $WINEPREFIXNAME!"
      exit 1
      ;;
  esac
}

wine-execute () {
  case "$WINEBRANCHNAME" in
    "bottles" | "bottles-noreqs")
      flatpak run --command='bottles-cli' com.usebottles.bottles run --bottle $WINEPREFIXNAME --executable "$@"
      ;;
    "$WINESTABLEBRANCH" | "$WINESTAGINGBRANCH" | "$WINEDEVELBRANCH")
      WINEPREFIX=$FULLWINEPREFIXPATH WINEARCH=$WINEARCH wine "$@"
      ;;
    *)
      echo "ERROR! Could not run executable for $WINEPREFIXNAME!"
      exit 1
      ;;
  esac
}

wine-reg-add () {
  key="$1"
  value="$2"
  type="$3"
  data="$4"
  case "$WINEBRANCHNAME" in
    "bottles" | "bottles-noreqs")
      flatpak run --command=bottles-cli com.usebottles.bottles reg --bottle $WINEPREFIXNAME --key "$key" --value "$value" --data "$data" --key-type "$type" add
      ;;
    "$WINESTABLEBRANCH" | "$WINESTAGINGBRANCH" | "$WINEDEVELBRANCH")
      WINEPREFIX=$FULLWINEPREFIXPATH WINEARCH=$WINEARCH wine reg add "$key" /v "$value" /t "$type" /d "$data" /f  
      ;;
    *)
      echo "ERROR! Could not add registry key for $WINEPREFIXNAME!"
      exit 1
      ;;
  esac
}

enable-vulkan-renderer () {
  case "$WINEBRANCHNAME" in
    "bottles" | "bottles-noreqs")
      flatpak run --command=bottles-cli com.usebottles.bottles edit --bottle $WINEPREFIXNAME --params renderer:vulkan
      ;;
    "$WINESTABLEBRANCH" | "$WINESTAGINGBRANCH" | "$WINEDEVELBRANCH")
      install-winetricks-verbs "renderer=vulkan"
      ;;
    *)
      echo "ERROR! Could not enable vulkan renderer for $WINEPREFIXNAME!"
      exit 1
      ;;
  esac
}

enable-dxvk () {
  case "$WINEBRANCHNAME" in
    "bottles" | "bottles-noreqs")
      flatpak run --command=bottles-cli com.usebottles.bottles edit --bottle $WINEPREFIXNAME --params dxvk:true
      ;;
    "$WINESTABLEBRANCH" | "$WINESTAGINGBRANCH" | "$WINEDEVELBRANCH")
      install-winetricks-verbs "dxvk"
      ;;
    *)
      echo "ERROR! Could not install dxvk to $WINEPREFIXNAME!"
      exit 1
      ;;
  esac
}

enable-vkd3d () {
  case "$WINEBRANCHNAME" in
    "bottles" | "bottles-noreqs")
      flatpak run --command=bottles-cli com.usebottles.bottles edit --bottle $WINEPREFIXNAME --params vkd3d:true
      ;;
    "$WINESTABLEBRANCH" | "$WINESTAGINGBRANCH" | "$WINEDEVELBRANCH")
      install-winetricks-verbs "vkd3d"
      ;;
    *)
      echo "ERROR! Could not install vkd3d to $WINEPREFIXNAME!"
      exit 1
      ;;
  esac
}