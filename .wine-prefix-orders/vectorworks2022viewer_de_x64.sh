#!/usr/bin/env bash

# Usage: Do not use directly! Only use 'wine-prefix-installer.sh' to call wine-prefix-orders!
# Apart from that: $WINEPREFIXORDERS/$REQUESTEDWINEPREFIXORDER.sh $WINEPREFIXFOLDER

### Constant declarations ###

WINEARCH="win64"
EXEDOWNLOADLINK="https://cw-downloads.eu/vectorworksviewer/Vectorworks-Viewer-2022.exe"

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
wine-install-prerequisites corefonts

wine-reboot

# Workaround: Since the setup file extracts everything into the folder, where it's executed, the setup file is copied into the prefix and started from there.
SETUPFILEFOLDER=$FULLWINEPREFIXPATH/drive_c/vectorworks2022viewerinstaller
mkdir -p $SETUPFILEFOLDER
cp -fv $SETUPFILEPATH $SETUPFILEFOLDER/
cd $SETUPFILEFOLDER

$SUBSCRIPT/highlighted-output.sh \
  "The script will now start '$SETUPFILENAME'." \
  "Install Mono and Gecko, if any windows ask for it."

wine-execute $SETUPFILEFOLDER/$SETUPFILENAME

# Let script wait until user interacts (until installation aborted.)
while [ true ] ; do
  read -t 3 -n 1
  if [ $? = 0 ] ; then
    break
  else
    $SUBSCRIPT/highlighted-output.sh "INFORMATION!" \
      "Let the firstly appearing graphical application unpack all files." \
      "Abort the secondly appearing graphical Vectorworks Viewer installer, when it shows up, and then hit enter here within terminal." \
      "Vectorworks Viewer 2022 will then install automatically." \
      "Install Mono and Gecko, if any windows ask for it."
  fi
done

wine-execute $SETUPFILEFOLDER/Vectorworks-Viewer-2022/resources/installer/Install\ Vectorworks2022.exe --unattendedmodeui minimal --mode unattended

$SUBSCRIPT/highlighted-output.sh \
  "Installation finished." \
  "Install Mono and Gecko, if any windows ask for it."