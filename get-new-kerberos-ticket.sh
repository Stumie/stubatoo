#!/usr/bin/env bash

# Designed for and only tested on Debian Linux 11, but might work on other distributions or versions as well

### Variable declarations ###

THISSCRIPTPATH=$(readlink -f $0)
THISDIRPATH=$(dirname $THISSCRIPTPATH)
SUBSCRIPT=$THISDIRPATH/.scripts

### Function declarations ###

source $SUBSCRIPT/optain-password.sh

### Procedures ###

$SUBSCRIPT/check-for-software-existence.sh sudo systemctl kinit klist

optain-password

echo $password | sudo -S systemctl restart sssd > /dev/null 2>&1

echo $password | sudo --user=$USER -S kinit > /dev/null 2>&1

$SUBSCRIPT/highlighted-output.sh "$(klist)"

unset password