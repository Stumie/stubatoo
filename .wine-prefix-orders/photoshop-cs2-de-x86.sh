#!/usr/bin/env bash

# Usage: $WINEPREFIXORDERS/$REQUESTEDWINEPREFIXORDER.sh $WINEPREFIXFOLDER

### Constant declarations ###

WINEARCH="win32"
EXEDOWNLOADLINK="https://securedl.cdn.chip.de/downloads/18076487/PS_CS2_Gr_NonRet.exe"

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
install-winetricks-verbs winxp corefonts

# Update and reboot wine prefix
WINEPREFIX=$FULLWINEPREFIXPATH WINEARCH=$WINEARCH wineboot -u
WINEPREFIX=$FULLWINEPREFIXPATH WINEARCH=$WINEARCH wineboot -r

$SUBSCRIPT/highlighted-output.sh \
  "The script will now install '$SETUPFILENAME'. Follow the installer's instructions, if necessary." \
  "Install Mono and Gecko, if any windows ask for it." \
  "You might find the license here: https://archive.fo/255q5#selection-1663.0-1663.29"

WINEPREFIX=$FULLWINEPREFIXPATH WINEARCH=$WINEARCH wine $SETUPFILEPATH

$SUBSCRIPT/highlighted-output.sh \
  "Installation finished." \
  "Install Mono and Gecko, if any windows ask for it." \
  "You might find the license here: https://archive.fo/255q5#selection-1663.0-1663.29"