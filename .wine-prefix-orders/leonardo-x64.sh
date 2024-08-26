#!/usr/bin/env bash

# Usage: $WINEPREFIXORDERS/$REQUESTEDWINEPREFIXORDER.sh $WINEPREFIXFOLDER

# Tested working: 
# - Fedora Kinoite 40, bottles-noreqs, caffe-9.7

### Constant declarations ###

WINEARCH="win64"
EXEDOWNLOADLINK="https://s3-eu-west-1.amazonaws.com/leonardo-installers/leonardo.0.17.70.winstall.exe"
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

# Download Leonardo setup file
download $EXEDOWNLOADLINK

# Download SegoeUi for Workaround further below
download $SEGOEUITTFDOWNLOADLINK

wine-prepare

# Set Windows Version to Windows 7
wine-set-winver win10

# Install necessary prerequisites 
wine-install-prerequisites courier

# Workaround: Since winetricks currently does not offer SegoeUi, we download it over fontsforyou.com and add it to the prefix.
cp -fv $DOWNLOADFOLDER/$(basename $SEGOEUITTFDOWNLOADLINK) $FULLWINEPREFIXPATH/drive_c/windows/Fonts/segoeui.ttf
wine-reg-add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" "SegoeUi (TrueType)" "REG_SZ" "segoeui.ttf"

wine-reboot

$SUBSCRIPT/highlighted-output.sh \
  "The script will now install '$SETUPFILENAME'. Follow the installer's instructions, if necessary." \
  "Install Mono and Gecko, if any windows ask for it."

wine-execute $SETUPFILEPATH

$SUBSCRIPT/highlighted-output.sh \
  "Installation finished." \
  "You may ignore the error message 'Failed executing ShowWindowAsync() on init', when starting Leonardo." \
  "Install Mono and Gecko, if any windows ask for it."