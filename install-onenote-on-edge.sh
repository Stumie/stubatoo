#!/usr/bin/env bash

set -e

if ! command -v "microsoft-edge" &> /dev/null; then
  printf '%s\n' "ERROR! Microsoft Edge needs to be installed, but could not be found, exiting."
  exit 1
fi

if [[ "$1" != "" ]]; then
  NOTEBOOKURL=$1
else
  printf '%s\n' "ERROR! You need to pass the full URL to the OneNote notebook, you want to open with the new starter icon, in the first parameter of this script."
  exit 1
fi

THISSCRIPTPATH=$(readlink -f $0)
THISDIRPATH=$(dirname $THISSCRIPTPATH)
TARGETHOMEDIRECTORY=$(eval echo ~$LOGNAME)
SVGDOWNLOADURL="https://res-1.cdn.office.net/files/fabric-cdn-prod_20230815.002/assets/brand-icons/product/svg/onenote_48x1.svg"

mkdir -vp "$TARGETHOMEDIRECTORY/.local/share/applications/"
mkdir -vp "$TARGETHOMEDIRECTORY/.icons/"
wget -v "$SVGDOWNLOADURL"
mv -v "$(basename "$SVGDOWNLOADURL")" "$TARGETHOMEDIRECTORY/.icons/microsoft-onenote.svg"

cat << EOF > $TARGETHOMEDIRECTORY/.local/share/applications/microsoft-onenote-web.desktop
#!/usr/bin/env xdg-open
[Desktop Entry]
Exec=microsoft-edge --app='$NOTEBOOKURL'
Name=Microsoft OneNote (Web)
Name[de]=Microsoft OneNote (Web)
Icon=$TARGETHOMEDIRECTORY/.icons/microsoft-onenote.svg
StartupNotify=true
Terminal=false
Type=Application
Categories=Office
X-KDE-RunOnDiscreteGpu=false
X-KDE-SubstituteUID=false
EOF

exit 0