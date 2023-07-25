#!/usr/bin/env bash

# Usage: `bash install-outlook-on-edge.sh "Max.Mustermann@mailprivder.com"`

if ! command -v "microsoft-edge" &> /dev/null; then
  printf '%s\n' "ERROR! Microsoft Edge needs to be installed, but could not be found, exiting."
  exit 1
fi

if [[ "$1" != "" ]]; then
  EMAILADDRESS=$1
else
  printf '%s\n' "ERROR! You need to pass the e-mail address, you want to use Outlook with, in the first parameter."
  exit 1
fi

THISSCRIPTPATH=$(readlink -f $0)
THISDIRPATH=$(dirname $THISSCRIPTPATH)
TARGETHOMEDIRECTORY=$(eval echo ~$LOGNAME)

mkdir -vp "$TARGETHOMEDIRECTORY/.local/share/applications/" && \
mkdir -vp "$TARGETHOMEDIRECTORY/.local/share/icons/" && \
cp -vf "$THISDIRPATH/icons/microsoft-outlook.ico" "$TARGETHOMEDIRECTORY/.local/share/icons/" && \

cat << EOF > $TARGETHOMEDIRECTORY/.local/share/applications/microsoft-outlook-web.desktop
#!/usr/bin/env xdg-open
[Desktop Entry]
Exec=microsoft-edge --app="https://outlook.office.com/owa/?login_hint=$EMAILADDRESS"
Name=Microsoft Outlook (Web)
Name[de]=Microsoft Outlook (Web)
GenericName=Groupware Suite
GenericName[de]=Groupware-Suite
Icon=$TARGETHOMEDIRECTORY/.local/share/icons/microsoft-outlook.ico
Keywords=email;calendar;contact;addressbook;task;
Keywords[de]=Mail;E-Mail;Nachricht;Kalender;Kontakt;Adressbuch;Aufgabe;
StartupNotify=true
Terminal=false
Type=Application
Categories=Office;Email;Calendar;ContactManagement;Network
X-KDE-RunOnDiscreteGpu=false
X-KDE-SubstituteUID=false
EOF

exit 0