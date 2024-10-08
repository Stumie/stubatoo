#!/usr/bin/env bash

# Usage: Do not use directly! Only use 'wine-prefix-installer.sh' to call wine-prefix-orders!
# Apart from that: $WINEPREFIXORDERS/$REQUESTEDWINEPREFIXORDER.sh $WINEPREFIXFOLDER

### Constant declarations ###

WINEARCH="win64"

### Imports and variable declarations ###

THISSCRIPTPATH=$(readlink -f $0)
THISDIRPATH=$(dirname $THISSCRIPTPATH)
SUBSCRIPT=$THISDIRPATH/../.scripts

source $SUBSCRIPT/wine-install-abstraction-layer.sh

DOWNLOADFOLDER=$WINEPREFIXFOLDER/tmp-downloads/$WINEPREFIXNAME

### Procedures ###

# Outcomment the lines below to start using the template 
# IMPORTANT! All downloads need to happen before 'wine-prepare'

#download "https://dl.winehq.org/wine/wine-mono/4.5.0/wine-mono-4.5.0.msi"
#wine-prepare
#wine-set-winver win7

$SUBSCRIPT/highlighted-output.sh \
  "The only is a template. Use it for copy-and-paste."