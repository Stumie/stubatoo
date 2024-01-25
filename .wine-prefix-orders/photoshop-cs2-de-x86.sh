#!/usr/bin/env bash

# Usage: $WINEPREFIXORDERS/$REQUESTEDWINEPREFIXORDER.sh $WINEPREFIXFOLDER

### Constant declarations ###

WINEARCH="win32"
EXEDOWNLOADLINK="https://securedl.cdn.chip.de/downloads/18076487/PS_CS2_Gr_NonRet.exe"

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
wine-set-winver winxp

# Install necessary prerequisites 
wine-install-prerequisites corefonts

wine-reboot

$SUBSCRIPT/highlighted-output.sh \
  "The script will now install '$SETUPFILENAME'. Follow the installer's instructions, if necessary." \
  "Install Mono and Gecko, if any windows ask for it." \
  "You might find the license here: https://archive.fo/255q5#selection-1663.0-1663.29"

wine-execute $SETUPFILEPATH

$SUBSCRIPT/highlighted-output.sh \
  "Installation finished." \
  "Install Mono and Gecko, if any windows ask for it." \
  "You might find the license here: https://archive.fo/255q5#selection-1663.0-1663.29"