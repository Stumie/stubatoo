#!/usr/bin/env bash

# Usage within script: 
# source $SUBSCRIPT/obtain-password.sh
# obtain-password

### Function declarations ###

ask-for-password () {
  passwordpromptstring="Please type in password for $USER: "
  if command -v kdialog &> /dev/null && kdialog -h &> /dev/null; then
    password=$(kdialog --password "$passwordpromptstring") # Prompts for KDE-specific askpass
  elif command -v zenity &> /dev/null && zenity -h &> /dev/null; then
    password=$(zenity --password) # Prompts for GTK-specific askpass
  elif command -v ssh-askpass &> /dev/null && ssh-askpass -h &> /dev/null; then
    password=$(ssh-askpass) # Prompts for window environment agnostic, but still graphical ssh-askpass
  elif command -v /lib/cryptsetup/askpass &> /dev/null; then
    password=$(/lib/cryptsetup/askpass "$passwordpromptstring") # Prompts for password within terminal
  elif command -v systemd-ask-password &> /dev/null; then
    password=$(systemd-ask-password "$passwordpromptstring") # Prompts for password within terminal
  elif command -v read &> /dev/null; then
    read -p "$passwordpromptstring" -s password
  else
    printf '%s\n' "ERROR! Could not ask for password because of missing possibilites!" >&2
    exit 1
  fi
}

obtain-password () {
  passwordiscorrect=false
  until [ $passwordiscorrect == true ]; do
    ask-for-password
    if [ -v $password ]; then
      printf '%s\n' "ERROR! Dialogue aborted or password left empty!" >&2
      unset password
      exit 1
    fi
    if echo $password | su -c true "$USER" > /dev/null 2>&1; then
      passwordiscorrect=true
    fi
  done
}