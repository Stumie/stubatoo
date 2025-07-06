#!/usr/bin/env bash

# Thanks to the dockur guys!
# dockur/windows GitHub repo: https://github.com/dockur/windows

### Constant declarations ###

winworkname="windows11"
windisksize="256G"
winramsize="8G"
wincpucores="4"
winlanguage="German"
winregion="de-DE"
winkeyboard="de-DE"
windowsfolder=${HOME:-.}/$winworkname

### Variable declarations ###

THISSCRIPTPATH=$(readlink -f $0)
THISDIRPATH=$(dirname $THISSCRIPTPATH)
SUBSCRIPT=$THISDIRPATH/.scripts

### Procedures ###

source $SUBSCRIPT/root-protection.sh
root-protection || exit 1
$SUBSCRIPT/check-for-software-existence.sh podman || exit 1

mkdir -p $windowsfolder
podman run \
    -it \
    --rm \
    --name "$winworkname" \
    --device=/dev/kvm \
    --device=/dev/net/tun \
    --network pasta:-t,127.0.0.1/8006:8006,-t,127.0.0.1/3389:3389,-u,127.0.0.1/3389:3389 \
    -v "$windowsfolder:/storage:z" \
    --stop-timeout 120 \
    --uidmap "+0:@$(id -u)" \
    -e VERSION="11" \
    -e DISK_SIZE="$windisksize" \
    -e RAM_SIZE="$winramsize" \
    -e CPU_CORES="$wincpucores" \
    -e LANGUAGE="$winlanguage" \
    -e REGION="$winkeyboard" \
    -e KEYBOARD="$winkeyboard" \
    -e NETWORK="user" \
    docker.io/dockurr/windows:latest