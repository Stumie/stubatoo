#!/usr/bin/env bash

### Function declarations ###

parameter-count-check () {
  countofgivenparameters=$1
  correctparamentercount=$2
  if [[ "$countofgivenparameters" != "$correctparamentercount" ]]; then
    printf '%s\n' "ERROR! You provided $countofgivenparameters parameters to the script, but it should be $correctparamentercount!" >&2
    show-usage
    exit 1
  fi
}