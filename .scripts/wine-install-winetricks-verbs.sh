#!/usr/bin/env bash

# Usage: Do not use directly! Use the function 'wine-install-prerequisites' from '$SUBSCRIPT/wine-install-abstraction-layer.sh' instead!
# Apart from that: 
# source $SUBSCRIPT/wine-install-abstraction-layer.sh
# install-winetricks-verbs "package"

### Function declarations ###

# This is a fix to avoid abortion of installation of all verbs, which already tends to happen, even if only one installation fails
install-winetricks-verbs () {
  winetricksverbs=$@
  for n in ${winetricksverbs[*]}; do
      WINEPREFIX=$FULLWINEPREFIXPATH WINEARCH=$WINEARCH winetricks --unattended --force $n
  done
}