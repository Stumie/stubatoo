#!/usr/bin/env bash

### Function declarations ###

root-protection () {
  if [ "$(id -u)" = "0" ]; then
    printf '%s\n' "ERROR! This script must not be run as root!" >&2
    return 1
  fi
}