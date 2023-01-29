#!/usr/bin/env bash

### Constant declarations ###

WORKSPACE="$HOME/workspace"

### Procedures ###

cd $WORKSPACE
for n in */
do
    cd $n
    git pull
    cd ..
done