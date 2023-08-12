#!/usr/bin/env bash

# Usage: $WINEPREFIXORDERS/$REQUESTEDWINEPREFIXORDER.sh $WINEPREFIXFOLDER

### Constant declarations ###

WINEARCH="win32"

ODTDOWNLOADPAGE="https://www.microsoft.com/en-us/download/confirmation.aspx?id=49117"

WEBVIEWDOWNLOADLINK="https://go.microsoft.com/fwlink/p/?LinkId=2124703"
WEBVIEWSETUPFILENAME="microsoftedgewebview2setup.exe"

ELSCOREATWINEDLLDOTCOM="https://wikidll.com/download/7449/elscore.zip"

### Variable declarations ###

THISSCRIPTPATH=$(readlink -f $0)
THISDIRPATH=$(dirname $THISSCRIPTPATH)
SUBSCRIPT=$THISDIRPATH/../.scripts

source $SUBSCRIPT/wine-install-abstraction-layer.sh

DOWNLOADFOLDER=$WINEPREFIXFOLDER/tmp-downloads/$WINEPREFIXNAME
ODTEXEDOWNLOADLINK="$(curl -s "$ODTDOWNLOADPAGE" | grep -Po 'href="https://[^"]+\.(exe)"' | grep -Po 'https://[^"]+' | tail -1)"
SETUPFILENAME=$(basename $ODTEXEDOWNLOADLINK)
SETUPFILEPATH=$DOWNLOADFOLDER/$SETUPFILENAME
WEBVIEWSETUPPATH=$DOWNLOADFOLDER/$WEBVIEWSETUPFILENAME

### Procedures ###

wine-prepare

# Download ODT
download $ODTEXEDOWNLOADLINK

# Download MS Edge WebView
download-followlink $WEBVIEWDOWNLOADLINK $WEBVIEWSETUPFILENAME

# Download elscore.dll
download $ELSCOREATWINEDLLDOTCOM

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

# Prepare configuration for Office Deployment Tool
# Manual: https://learn.microsoft.com/en-us/deployoffice/office-deployment-tool-configuration-options
# Product ID hints: https://learn.microsoft.com/en-us/microsoft-365/troubleshoot/installation/product-ids-supported-office-deployment-click-to-run
# Version hints: https://learn.microsoft.com/en-us/officeupdates/update-history-office-win7
mkdir -p $FULLWINEPREFIXPATH/drive_c/ODT
cat << EOF > $FULLWINEPREFIXPATH/drive_c/ODT/installOfficeProPlus32.xml
<Configuration>
  <Add OfficeClientEdition="32" Version="16.0.12527.22286">
    <Product ID="O365ProPlusRetail">
      <Language ID="MatchOS" Fallback="en-us" />
    </Product>
  </Add>
  <Display Level="Full" AcceptEULA="TRUE" />
</Configuration>
EOF

# Create Setup with Office Deployment Tool
wine-execute $SETUPFILEPATH /quiet /passive /norestart /extract:$FULLWINEPREFIXPATH/drive_c/ODT/

wine-reboot

$SUBSCRIPT/highlighted-output.sh \
  "The script will now start the Microsoft Office 365 installer." \
  "Follow the installer's instructions, if necessary." \
  "Install Mono and Gecko, if any windows ask for it."

wine-execute $FULLWINEPREFIXPATH/drive_c/ODT/setup.exe /configure "C:\ODT\installOfficeProPlus32.xml"

# Workaround: Symlink creation seems to be broken during installation, which is the reason, why DLLs have to be copied manually.
cp -fv $FULLWINEPREFIXPATH/drive_c/Program\ Files/Common\ Files/Microsoft\ Shared/ClickToRun/*.dll $FULLWINEPREFIXPATH/drive_c/Program\ Files/Microsoft\ Office/root/Office16/
cp -fv $FULLWINEPREFIXPATH/drive_c/Program\ Files/Common\ Files/Microsoft\ Shared/ClickToRun/*.dll $FULLWINEPREFIXPATH/drive_c/Program\ Files/Microsoft\ Office/root/Client/

# Workaround: Add elscore.dll for some programms to start
unzip -o $DOWNLOADFOLDER/$(basename $ELSCOREATWINEDLLDOTCOM) -d $DOWNLOADFOLDER
cp -fv $DOWNLOADFOLDER/ELSCore.dll $FULLWINEPREFIXPATH/drive_c/Program\ Files/Microsoft\ Office/root/Office16/
mv -fv $DOWNLOADFOLDER/ELSCore.dll $FULLWINEPREFIXPATH/drive_c/Program\ Files/Microsoft\ Office/root/Client/

# Remove ODT folder to save disk space
rm -rf $FULLWINEPREFIXPATH/drive_c/ODT

wine-reboot

$SUBSCRIPT/highlighted-output.sh \
  "Installation finished." \
  "Install Mono and Gecko, if any windows ask for it."