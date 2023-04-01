#!/usr/bin/env bash

# Usage: $WINEPREFIXORDERS/$REQUESTEDWINEPREFIXORDER.sh $WINEPREFIXFOLDER

### Constant declarations ###

WINEARCH="win64"
EXEDOWNLOADLINK="https://s3-eu-west-1.amazonaws.com/leonardo-installers/leonardo.0.17.66.winstall.exe"
SEGOEUITTFDOWNLOADLINK="https://fontsfree.net//wp-content/fonts/basic/sans-serif/FontsFree-Net-Segoe-UI.ttf"

### Variable declarations ###

THISSCRIPTPATH=$(readlink -f $0)
THISDIRPATH=$(dirname $THISSCRIPTPATH)
SUBSCRIPT=$THISDIRPATH/../.scripts

WINEPREFIXNAME=$(basename -s .sh $0)
WINEPREFIXFOLDER=$1
FULLWINEPREFIXPATH=$WINEPREFIXFOLDER/$WINEPREFIXNAME

DOWNLOADFOLDER=$WINEPREFIXFOLDER/tmp-downloads/$WINEPREFIXNAME
SETUPFILENAME=$(basename $EXEDOWNLOADLINK)
SETUPFILEPATH=$DOWNLOADFOLDER/$SETUPFILENAME

### Procedures ###

source $SUBSCRIPT/wine-install-winetricks-verbs.sh

$SUBSCRIPT/wine-prefix-download-software.sh $WINEPREFIXFOLDER $WINEPREFIXNAME $EXEDOWNLOADLINK || { printf '%s\n' "ERROR! Could not download file!" >&2 && exit 1; }

$SUBSCRIPT/wine-prefix-prepare-first-run.sh $WINEARCH $WINEPREFIXFOLDER $WINEPREFIXNAME || { printf '%s\n' "ERROR! Could not prepare wine prefix!" >&2 && exit 1; }

# Install the relevant set of wintricks
install-winetricks-verbs win10 courier

# Workaround: Since winetricks currently does not offer SegoeUi, we download it over fontsforyou.com and add it to the prefix.
wget $SEGOEUITTFDOWNLOADLINK -O $FULLWINEPREFIXPATH/drive_c/windows/Fonts/segoeui.ttf
WINEPREFIX=$FULLWINEPREFIXPATH WINEARCH=$WINEARCH wine reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" /v "SegoeUi (TrueType)" /t REG_SZ /d segoeui.ttf /f

# Update and reboot wine prefix
WINEPREFIX=$FULLWINEPREFIXPATH WINEARCH=$WINEARCH wineboot -u
WINEPREFIX=$FULLWINEPREFIXPATH WINEARCH=$WINEARCH wineboot -r

$SUBSCRIPT/highlighted-output.sh \
  "The script will now install '$SETUPFILENAME'. Follow the installer's instructions, if necessary." \
  "Install Mono and Gecko, if any windows ask for it."

WINEPREFIX=$FULLWINEPREFIXPATH WINEARCH=$WINEARCH wine $SETUPFILEPATH

$SUBSCRIPT/highlighted-output.sh \
  "Installation finished." \
  "Install Mono and Gecko, if any windows ask for it."