#!/usr/bin/env bash

# Usage: $WINEPREFIXORDERS/$REQUESTEDWINEPREFIXORDER.sh $WINEPREFIXFOLDER

### Constant declarations ###

WINEARCH="win32"

EXEDOWNLOADLINK="https://download.microsoft.com/download/2/7/A/27AF1BE6-DD20-4CB4-B154-EBAB8A7D4A7E/officedeploymenttool_16026-20170.exe"

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

SETUPFILENAME=$(basename $EXEDOWNLOADLINK)
SETUPFILEPATH=$DOWNLOADFOLDER/$SETUPFILENAME

WEBVIEWSETUPPATH=$DOWNLOADFOLDER/$WEBVIEWSETUPFILENAME

### Procedures ###

source $SUBSCRIPT/wine-install-winetricks-verbs.sh

$SUBSCRIPT/wine-prefix-download-software.sh $WINEPREFIXFOLDER $WINEPREFIXNAME $EXEDOWNLOADLINK || { printf '%s\n' "ERROR! Could not download software!" >&2 && exit 1; }
$SUBSCRIPT/wine-prefix-download-software-followlink.sh $WINEPREFIXFOLDER $WINEPREFIXNAME $WEBVIEWDOWNLOADLINK $WEBVIEWSETUPFILENAME  || { printf '%s\n' "ERROR! Could not download software!" >&2 && exit 1; }

$SUBSCRIPT/wine-prefix-prepare-first-run.sh $WINEARCH $WINEPREFIXFOLDER $WINEPREFIXNAME || { printf '%s\n' "ERROR! Could not prepare wine prefix!" >&2 && exit 1; }

# Install the relevant set of wintricks
install-winetricks-verbs win7 riched20 msxml6 corefonts pptfonts

# Add Wine registry keys for DLL overrides
$SUBSCRIPT/wine-prefix-add-registry-keys.sh prepare $FULLWINEPREFIXPATH
cat << EOF >> $FULLWINEPREFIXPATH/drive_c/tmp-regedit-import.reg
[HKEY_CURRENT_USER\Software\Wine\Direct2D]
"max_version_factory"=dword:0
[HKEY_CURRENT_USER\Software\Wine\Direct3D]
"MaxVersionGL"=dword:00030002
[HKEY_CURRENT_USER\Software\Wine\DllOverrides]
"sppc"=""
EOF
$SUBSCRIPT/wine-prefix-add-registry-keys.sh import $FULLWINEPREFIXPATH

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

# Prepare configuration for Office Deployment Tool
# Manual: https://learn.microsoft.com/en-us/deployoffice/office-deployment-tool-configuration-options
# Version hints: https://learn.microsoft.com/en-us/microsoft-365/troubleshoot/installation/product-ids-supported-office-deployment-click-to-run
mkdir -p $FULLWINEPREFIXPATH/drive_c/ODT
cat << EOF > $FULLWINEPREFIXPATH/drive_c/ODT/installOfficeProPlus32.xml
<Configuration>
  <Add OfficeClientEdition="32" Version="MatchInstalled" Channel="Current">
    <Product ID="O365ProPlusRetail">
      <Language ID="MatchInstalled" />
      <Language ID="MatchOS" Fallback="en-us" />
    </Product>
  </Add>
  <Display Level="Full" AcceptEULA="TRUE" />
</Configuration>
EOF

# Create Setup with Office Deployment Tool
WINEPREFIX=$FULLWINEPREFIXPATH WINEARCH=$WINEARCH wine $SETUPFILEPATH /quiet /passive /norestart /extract:$FULLWINEPREFIXPATH/drive_c/ODT/

# Update and reboot wine prefix
WINEPREFIX=$FULLWINEPREFIXPATH WINEARCH=$WINEARCH wineboot -u
WINEPREFIX=$FULLWINEPREFIXPATH WINEARCH=$WINEARCH wineboot -r

$SUBSCRIPT/highlighted-output.sh \
  "The script will now start the Microsoft Office 365 installer." \
  "Follow the installer's instructions, if necessary." \
  "Install Mono and Gecko, if any windows ask for it."

WINEPREFIX=$FULLWINEPREFIXPATH WINEARCH=$WINEARCH wine $FULLWINEPREFIXPATH/drive_c/ODT/setup.exe /configure "C:\ODT\installOfficeProPlus32.xml"

# Workaround: Symlink creation seems to be broken during installation, which is the reason, why DLLs have to be copied manually.
cp -fv $FULLWINEPREFIXPATH/drive_c/Program\ Files/Common\ Files/Microsoft\ Shared/ClickToRun/*.dll $FULLWINEPREFIXPATH/drive_c/Program\ Files/Microsoft\ Office/root/Office16/

# Remove ODT folder to save disk space
rm -rf $FULLWINEPREFIXPATH/drive_c/ODT

# Update and reboot wine prefix
WINEPREFIX=$FULLWINEPREFIXPATH WINEARCH=$WINEARCH wineboot -u
WINEPREFIX=$FULLWINEPREFIXPATH WINEARCH=$WINEARCH wineboot -r

$SUBSCRIPT/highlighted-output.sh \
  "Installation finished." \
  "Install Mono and Gecko, if any windows ask for it."