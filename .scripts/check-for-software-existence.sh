#!/usr/bin/env bash

### Procedures ###

  for i in $@
  do
    if ! command -v $i &> /dev/null; then
      printf '%s\n' "ERROR! $i is necessary, but could not be found, exiting."
      exit 1
    fi
  done