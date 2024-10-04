#!/usr/bin/env bash

# Usage: $SUBSCRIPT/elevated-run.sh "$SUBSCRIPT/$SOFTWARENAME-$DISTRIMARKER-reqs.sh "$SOFTWARENAMEBRANCH""

### Constant declarations ###

WINESTABLEBRANCH="stable"
WINESTAGINGBRANCH="staging"
WINEDEVELBRANCH="devel"

### Procedures - Part 1 ###

# Download and install requirements via APT
dpkg --add-architecture i386
apt-get update -y
apt-get upgrade -y
apt-get install -y software-properties-common coreutils grep zstd curl wget lsb-release fzf unzip p7zip-full

### Variable declarations - Part 2 ###

DISTRIRELEASE=$(lsb_release -is | awk '{print tolower($0)}')
DISTRIVERSION=$(lsb_release -cs | awk '{print tolower($0)}')
WINEBRANCHNAME=$1

### Procedures - Part 2 ###

if ! [ "$WINEBRANCHNAME" != "$WINESTABLEBRANCH" ] && [ "$WINEBRANCHNAME" != "$WINESTAGINGBRANCH" ] && [ "$WINEBRANCHNAME" != "$WINEDEVELBRANCH" ]; then

  rm /etc/apt/sources.list.d/winehq.sources /etc/apt/sources.list.d/winehq-*.sources
  wget -nc -O /usr/share/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
  wget -nc -O /etc/apt/sources.list.d/winehq.sources https://dl.winehq.org/wine-builds/$DISTRIRELEASE/dists/$DISTRIVERSION/winehq-$DISTRIVERSION.sources
  mkdir -pm755 /etc/apt/keyrings
  cp -fv /usr/share/keyrings/winehq-archive.key /etc/apt/keyrings/winehq-archive.key

  apt-get update -y
  apt-get upgrade -y
  apt-get install --install-recommends winehq-$WINEBRANCHNAME -y
  apt-get install winetricks cabextract p11-kit p11-kit-modules winbind samba smbclient -y

fi

if [[ "$WINEBRANCHNAME" = "bottles" ]]; then

  sudo apt-get update
  sudo apt-get upgrade -y
  sudo apt-get -y install flatpak winetricks coreutils grep fzf jq
  sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  sudo flatpak update -y
  sudo flatpak install flathub com.usebottles.bottles

fi

winetricks --unattended --self-update