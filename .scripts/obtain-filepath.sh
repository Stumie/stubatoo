#!/usr/bin/env bash

# Usage within script: 
# source $SUBSCRIPT/obtain-filepath.sh
# FILEPATH=$(ask-for-filepath)

### Function declarations ###

ask-for-filepath () {
  if command -v kdialog &> /dev/null && kdialog -h &> /dev/null; then
    echo $(kdialog --getopenfilename) # Prompts for KDE-specific file chooser
  elif command -v zenity &> /dev/null && zenity -h &> /dev/null; then
    echo $(zenity --file-selection) # Prompts for GTK-specific file chooser
  else
    printf '%s\n' "ERROR! Could not ask for file because of missing possibilites!" >&2
    exit 1
  fi
}