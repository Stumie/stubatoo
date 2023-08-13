#!/usr/bin/env bash

# Usage: $WINEPREFIXORDERS/$REQUESTEDWINEPREFIXORDER.sh $WINEPREFIXFOLDER

### Constant declarations ###

WINEARCH="win32"

WEBVIEWDOWNLOADLINK="https://go.microsoft.com/fwlink/p/?LinkId=2124703"
WEBVIEWSETUPFILENAME="microsoftedgewebview2setup.exe"

### Variable declarations ###

THISSCRIPTPATH=$(readlink -f $0)
THISDIRPATH=$(dirname $THISSCRIPTPATH)
SUBSCRIPT=$THISDIRPATH/../.scripts

source $SUBSCRIPT/wine-install-abstraction-layer.sh

DOWNLOADFOLDER=$WINEPREFIXFOLDER/tmp-downloads/$WINEPREFIXNAME
WEBVIEWSETUPPATH=$DOWNLOADFOLDER/$WEBVIEWSETUPFILENAME

### Procedures ###

source $SUBSCRIPT/obtain-filepath.sh

$SUBSCRIPT/highlighted-output.sh \
  "The script will now ask for the 32 bit setup file path of Microsoft Office 2016."

O2016SETUPFILEPATH=$(ask-for-filepath)

if [ $O2016SETUPFILEPATH == "" ] || ! [[ "$O2016SETUPFILEPATH" =~ .*".exe" ]]; then
  printf '%s\n' "ERROR! Could not find setup file!" >&2
  exit 1
fi

wine-prepare

# Download MS Edge WebView
download-followlink $WEBVIEWDOWNLOADLINK $WEBVIEWSETUPFILENAME

# Set Windows Version to Windows 7
wine-set-winver win7

# Install necessary prerequisites 
wine-install-prerequisites riched20 msxml6 corefonts tahoma pptfonts

# Add Wine registry keys for workarounds
wine-reg-add "HKCU\Software\Wine\Direct2D" "max_version_factory" "REG_DWORD" "0"
wine-reg-add "HKCU\Software\Wine\Direct3D" "MaxVersionGL" "REG_DWORD" "196610"
wine-reg-add "HKCU\Software\Wine\DllOverrides" "sppc" "REG_SZ" ""

# Make sure Wine prefix is set to Windows 7
wine-set-winver win7

wine-reboot

# Install Microsoft Edge WebView2 Runtime
$SUBSCRIPT/highlighted-output.sh \
  "The script will now install Microsoft Edge WebView2 Runtime in the background." \
  "Install Mono and Gecko, if any windows ask for it."
wine-execute $WEBVIEWSETUPPATH /silent /install

wine-reboot

$SUBSCRIPT/highlighted-output.sh \
  "The script will now start the Microsoft Office 2016 installer." \
  "Follow the installer's instructions, if necessary." \
  "Install Mono and Gecko, if any windows ask for it."

wine-execute $O2016SETUPFILEPATH

wine-reboot

$SUBSCRIPT/highlighted-output.sh \
  "Installation finished." \
  "Install Mono and Gecko, if any windows ask for it."