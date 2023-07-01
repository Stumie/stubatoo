#!/usr/bin/env bash

# Usage: $WINEPREFIXORDERS/$REQUESTEDWINEPREFIXORDER.sh $WINEPREFIXFOLDER

### Constant declarations ###

WINEARCH="win64"
EXEDOWNLOADLINK="https://archive.org/download/sketchup-make-2017-de-x64/SketchUpMake-de-x64.exe"

### Imports and variable declarations ###

THISSCRIPTPATH=$(readlink -f $0)
THISDIRPATH=$(dirname $THISSCRIPTPATH)
SUBSCRIPT=$THISDIRPATH/../.scripts

source $SUBSCRIPT/wine-install-abstraction-layer.sh

DOWNLOADFOLDER=$WINEPREFIXFOLDER/tmp-downloads/$WINEPREFIXNAME
SETUPFILENAME=$(basename $EXEDOWNLOADLINK)
SETUPFILEPATH=$DOWNLOADFOLDER/$SETUPFILENAME

### Procedures ###

wine-prepare

download $EXEDOWNLOADLINK

# Set Windows Version to Windows 7
wine-set-winver win7

# Install necessary prerequisites 
wine-install-prerequisites corefonts

# Add Wine registry keys for workarounds
wine-reg-add "HKCU\Software\Wine\DllOverrides" "libglesv2" "REG_SZ" ""
wine-reg-add "HKCU\Software\Wine\DllOverrides" "riched20" "REG_SZ" "native,builtin"

wine-update-and-reboot

$SUBSCRIPT/highlighted-output.sh \
  "The script will now install '$SETUPFILENAME'. Follow the SketchUp installer's instructions." \
  "Install Visual C++, when the SketchUp installer asks for it." \
  "Install Mono and Gecko, if any windows ask for it."

wine-execute $SETUPFILEPATH

$SUBSCRIPT/highlighted-output.sh \
  "Installation finished." \
  "Install Mono and Gecko, if any windows ask for it."