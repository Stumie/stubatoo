#!/usr/bin/env bash

# Usage within script: 
# source $SUBSCRIPT/parameter-count-check.sh
# parameter-count-check $# n || {  exit 1; }
# ...

### Function declarations ###

parameter-count-check () {
  countofgivenparameters=$1
  correctparamentercount=$2
  if [[ "$countofgivenparameters" != "$correctparamentercount" ]]; then
    printf '%s\n' "ERROR! You provided $countofgivenparameters parameters to the script, but it should be $correctparamentercount!" >&2
    return 1
  fi
}