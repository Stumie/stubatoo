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

source $SUBSCRIPT/wine-install-abstraction-layer.sh

DOWNLOADFOLDER=$WINEPREFIXFOLDER/tmp-downloads/$WINEPREFIXNAME
SETUPFILENAME=$(basename $EXEDOWNLOADLINK)
SETUPFILEPATH=$DOWNLOADFOLDER/$SETUPFILENAME

### Procedures ###

download $EXEDOWNLOADLINK

wine-prepare

# Set Windows Version to Windows 7
wine-set-winver win10

# Install necessary prerequisites 
wine-install-prerequisites courier

# Workaround: Since winetricks currently does not offer SegoeUi, we download it over fontsforyou.com and add it to the prefix.
wget $SEGOEUITTFDOWNLOADLINK -O $FULLWINEPREFIXPATH/drive_c/windows/Fonts/segoeui.ttf
WINEPREFIX=$FULLWINEPREFIXPATH WINEARCH=$WINEARCH wine reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" /v "SegoeUi (TrueType)" /t REG_SZ /d segoeui.ttf /f

wine-reboot

$SUBSCRIPT/highlighted-output.sh \
  "The script will now install '$SETUPFILENAME'. Follow the installer's instructions, if necessary." \
  "Install Mono and Gecko, if any windows ask for it."

wine-execute $SETUPFILEPATH

$SUBSCRIPT/highlighted-output.sh \
  "Installation finished." \
  "You may ignore the error message 'Failed executing ShowWindowAsync() on init', when starting Leonardo." \
  "Install Mono and Gecko, if any windows ask for it."