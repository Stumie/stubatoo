#!/usr/bin/env bash

# Usage: Do not use directly! Only use 'wine-prefix-installer.sh' to call wine-prefix-orders!
# Apart from that: $WINEPREFIXORDERS/$REQUESTEDWINEPREFIXORDER.sh $WINEPREFIXFOLDER

# Tested working: 
# - Fedora Kinoite 40, bottles-noreqs, soda-9.0-1

### Constant declarations ###

WINEARCH="win32"
EXEDOWNLOADLINK="https://securedl.cdn.chip.de/downloads/18076522/ID_CS2_GR_NonRet.exe"

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

# Set Windows Version
wine-set-winver winxp

# Install necessary prerequisites 
wine-install-prerequisites vb5run corefonts

# Add Wine registry keys for workarounds
wine-reg-add "HKCU\Software\Wine\DllOverrides" "oleauth32" "REG_SZ" "native,builtin"

wine-reboot

$SUBSCRIPT/highlighted-output.sh \
  "The script will now install '$SETUPFILENAME'. Follow the installer's instructions, if necessary." \
  "Install Mono and Gecko, if any windows ask for it." \
  "You might find the license here: https://archive.fo/255q5#selection-1621.0-1621.29"

wine-execute $SETUPFILEPATH

$SUBSCRIPT/highlighted-output.sh \
  "Installation finished." \
  "Install Mono and Gecko, if any windows ask for it." \
  "You might find the license here: https://archive.fo/255q5#selection-1621.0-1621.29"
