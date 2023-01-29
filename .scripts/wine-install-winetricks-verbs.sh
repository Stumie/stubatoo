#!/usr/bin/env bash

### Function declarations ###

# This is a fix to avoid abortion of installation of all verbs, which already tends to happen, even if only one installation fails
install-winetricks-verbs () {
  winetricksverbs=$@
  for n in ${winetricksverbs[*]}; do
      WINEPREFIX=$FULLWINEPREFIXPATH WINEARCH=$WINEARCH winetricks --unattended --force $n
  done
}