#!/usr/bin/env bash

# Usage: $WINEPREFIXORDERS/$REQUESTEDWINEPREFIXORDER.sh $WINEPREFIXFOLDER

### Constant declarations ###

WINEARCH="win64"
EXEDOWNLOADLINK="https://cw-downloads.eu/vectorworksviewer/Vectorworks-Viewer-2022.exe"

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
install-winetricks-verbs win10 corefonts

# Update and reboot wine prefix
WINEPREFIX=$FULLWINEPREFIXPATH WINEARCH=$WINEARCH wineboot -u
WINEPREFIX=$FULLWINEPREFIXPATH WINEARCH=$WINEARCH wineboot -r

SETUPFILEFOLDER=$FULLWINEPREFIXPATH/drive_c/vectorworks2022viewerinstaller
mkdir -p $SETUPFILEFOLDER
cp -fv $SETUPFILEPATH $SETUPFILEFOLDER/
cd $SETUPFILEFOLDER

$SUBSCRIPT/highlighted-output.sh \
  "The script will now start '$SETUPFILENAME'." \
  "Install Mono and Gecko, if any windows ask for it."

WINEPREFIX=$FULLWINEPREFIXPATH WINEARCH=$WINEARCH wine $SETUPFILEFOLDER/$SETUPFILENAME

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

WINEPREFIX=$FULLWINEPREFIXPATH WINEARCH=$WINEARCH wine $SETUPFILEFOLDER/Vectorworks-Viewer-2022/resources/installer/Install\ Vectorworks2022.exe --unattendedmodeui minimal --mode unattended

$SUBSCRIPT/highlighted-output.sh \
  "Installation finished." \
  "Install Mono and Gecko, if any windows ask for it."