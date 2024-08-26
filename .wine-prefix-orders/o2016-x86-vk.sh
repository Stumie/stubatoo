#!/usr/bin/env bash

# Usage: $WINEPREFIXORDERS/$REQUESTEDWINEPREFIXORDER.sh $WINEPREFIXFOLDER

# Tested working: 
# - Fedora Kinoite 40, bottles-noreqs, caffe-7.20

### Constant declarations ###

WINEARCH="win32"

### Variable declarations ###

THISSCRIPTPATH=$(readlink -f $0)
THISDIRPATH=$(dirname $THISSCRIPTPATH)
SUBSCRIPT=$THISDIRPATH/../.scripts

source $SUBSCRIPT/wine-install-abstraction-layer.sh
source $SUBSCRIPT/obtain-filepath.sh

### Procedures ###

$SUBSCRIPT/highlighted-output.sh \
  "The script will now ask for the 32 bit setup file path of Microsoft Office 2016." \
  "Warning! There're issues with Click-to-Run (C2R) installers of Office, which might just fail during installation."
$SUBSCRIPT/press-any-key-helper.sh

O2016SETUPFILEPATH=$(ask-for-filepath)

if [[ "$O2016SETUPFILEPATH" = "" ]] || ! [[ "$O2016SETUPFILEPATH" =~ .*".exe" ]]; then
  printf '%s\n' "ERROR! Could not find setup file!" >&2
  exit 1
fi

wine-prepare

# Set Windows Version
wine-set-winver win7

# Install necessary prerequisites 
wine-install-prerequisites msxml6 riched20 corefonts tahoma pptfonts

enable-vulkan-renderer

# Add Wine registry keys for workarounds
wine-reg-add "HKCU\Software\Wine\Direct2D" "max_version_factory" "REG_DWORD" "0"
wine-reg-add "HKCU\Software\Wine\Direct3D" "MaxVersionGL" "REG_DWORD" "196610"

# Make sure Wine prefix is set to Windows 7
wine-set-winver win7

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