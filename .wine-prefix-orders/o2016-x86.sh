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

WINEPREFIXNAME=$(basename -s .sh $0)
WINEPREFIXFOLDER=$1
FULLWINEPREFIXPATH=$WINEPREFIXFOLDER/$WINEPREFIXNAME

DOWNLOADFOLDER=$WINEPREFIXFOLDER/tmp-downloads/$WINEPREFIXNAME

WEBVIEWSETUPPATH=$DOWNLOADFOLDER/$WEBVIEWSETUPFILENAME

### Procedures ###

source $SUBSCRIPT/wine-install-winetricks-verbs.sh
source $SUBSCRIPT/obtain-filepath.sh

$SUBSCRIPT/highlighted-output.sh \
  "The script will now ask for the 32 bit setup file path of Microsoft Office 2016."

O2016SETUPFILEPATH=$(ask-for-filepath)

if [ $O2016SETUPFILEPATH == "" ] || ! [[ "$O2016SETUPFILEPATH" =~ .*".exe" ]]; then
  printf '%s\n' "ERROR! Could not find setup file!" >&2
  exit 1
fi

# Download MS Edge WebView
$SUBSCRIPT/wine-prefix-download-software-followlink.sh $WINEPREFIXFOLDER $WINEPREFIXNAME $WEBVIEWDOWNLOADLINK $WEBVIEWSETUPFILENAME  || { printf '%s\n' "ERROR! Could not download file!" >&2 && exit 1; }

# Prepare first run of Wine prefix
$SUBSCRIPT/wine-prefix-prepare-first-run.sh $WINEARCH $WINEPREFIXFOLDER $WINEPREFIXNAME || { printf '%s\n' "ERROR! Could not prepare wine prefix!" >&2 && exit 1; }

# Install the relevant set of wintricks
install-winetricks-verbs win7 riched20 msxml6 corefonts pptfonts

# Add Wine registry keys for workarounds
WINEPREFIX=$FULLWINEPREFIXPATH WINEARCH=$WINEARCH wine reg add "HKCU\Software\Wine\Direct2D" /v "max_version_factory" /t REG_DWORD /d "0" /f
WINEPREFIX=$FULLWINEPREFIXPATH WINEARCH=$WINEARCH wine reg add "HKCU\Software\Wine\Direct3D" /v "MaxVersionGL" /t REG_DWORD /d "196610" /f  
WINEPREFIX=$FULLWINEPREFIXPATH WINEARCH=$WINEARCH wine reg add "HKCU\Software\Wine\DllOverrides" /v "sppc" /t REG_SZ /d "" /f

# Make sure Wine prefix is set to Windows 7
WINEPREFIX=$FULLWINEPREFIXPATH WINEARCH=$WINEARCH winecfg -v win7

# Update and reboot wine prefix
WINEPREFIX=$FULLWINEPREFIXPATH WINEARCH=$WINEARCH wineboot -u
WINEPREFIX=$FULLWINEPREFIXPATH WINEARCH=$WINEARCH wineboot -r

# Install Microsoft Edge WebView2 Runtime
$SUBSCRIPT/highlighted-output.sh \
  "The script will now install Microsoft Edge WebView2 Runtime in the background." \
  "Install Mono and Gecko, if any windows ask for it."
WINEPREFIX=$FULLWINEPREFIXPATH WINEARCH=$WINEARCH wine $WEBVIEWSETUPPATH /silent /install

# Update and reboot wine prefix
WINEPREFIX=$FULLWINEPREFIXPATH WINEARCH=$WINEARCH wineboot -u
WINEPREFIX=$FULLWINEPREFIXPATH WINEARCH=$WINEARCH wineboot -r

$SUBSCRIPT/highlighted-output.sh \
  "The script will now start the Microsoft Office 2016 installer." \
  "Follow the installer's instructions, if necessary." \
  "Install Mono and Gecko, if any windows ask for it."

WINEPREFIX=$FULLWINEPREFIXPATH WINEARCH=$WINEARCH wine $O2016SETUPFILEPATH

# Update and reboot wine prefix
WINEPREFIX=$FULLWINEPREFIXPATH WINEARCH=$WINEARCH wineboot -u
WINEPREFIX=$FULLWINEPREFIXPATH WINEARCH=$WINEARCH wineboot -r

$SUBSCRIPT/highlighted-output.sh \
  "Installation finished." \
  "Install Mono and Gecko, if any windows ask for it."