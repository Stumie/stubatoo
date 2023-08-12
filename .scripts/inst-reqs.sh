#!/usr/bin/env bash

# Usage: $SUBSCRIPT/inst-reqs.sh $SOFTWARENAME $WINEBRANCHNAME || { printf '%s\n' "ERROR! Could not install requirements!" >&2 && exit 1; }

### Variable declarations ###

THISSCRIPTPATH=$(readlink -f $0)
THISDIRPATH=$(dirname $THISSCRIPTPATH)
SUBSCRIPT=$THISDIRPATH

SOFTWARENAME=$1
SOFTWARENAMEBRANCH=$2

### Procedures ###

$SUBSCRIPT/highlighted-output.sh "The script will now update packages and install prerequisites."

if [ -f "/etc/debian_version" ]; then
  if [[ "$(uname -v)" =~ .*"Debian".* || "$(lsb_release -is)" == "Debian" ]]; then
    printf '%s\n' "Debian Linux detected."
    $SUBSCRIPT/elevated-run.sh "$SUBSCRIPT/$SOFTWARENAME-debian-reqs.sh "$SOFTWARENAMEBRANCH""
  elif [[ "$(uname -v)" =~ .*"Ubuntu".* ]]; then
    printf '%s\n' "Ubuntu Linux detected. Trying Debian requirements, what should work for Ubuntu as well."
    $SUBSCRIPT/elevated-run.sh "$SUBSCRIPT/$SOFTWARENAME-debian-reqs.sh "$SOFTWARENAMEBRANCH""
  else
    printf '%s\n' "Debian-derivate detected, but cannot decide which path to choose. Exit for safety reasons."
    exit 1
  fi
else 
  printf '%s\n' "ERROR! Currently there's no suitable routine to install requirements on your system." >&2
  exit 1
fi