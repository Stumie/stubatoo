#!/usr/bin/env bash

# Usage: $SUBSCRIPT/elevated-run.sh "$SUBSCRIPT/$SOFTWARENAME-$DISTRIMARKER-reqs.sh "$SOFTWARENAMEBRANCH""

### Procedures - Part 1 ###

# Download and install requirements via APT
dpkg --add-architecture i386
apt-get update -y
apt-get upgrade -y
apt-get install gcc make perl wget dos2unix unzip p7zip-full zstd lsb-release software-properties-common -y

### Variable declarations - Part 2 ###

DISTRIRELEASE=$(lsb_release -is | awk '{print tolower($0)}')
DISTRIVERSION=$(lsb_release -cs | awk '{print tolower($0)}')
WINEBRANCHNAME=$1

### Procedures - Part 2 ###

wget -nc -O /usr/share/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
wget -nc -P /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/$DISTRIRELEASE/dists/$DISTRIVERSION/winehq-$DISTRIVERSION.sources
mkdir -pm755 /etc/apt/keyrings
cp -fv /usr/share/keyrings/winehq-archive.key /etc/apt/keyrings/winehq-archive.key

apt-get update -y
apt-get install --install-recommends winehq-$WINEBRANCHNAME -y
apt-get install winetricks cabextract p11-kit p11-kit-modules winbind samba smbclient -y

winetricks --unattended --self-update