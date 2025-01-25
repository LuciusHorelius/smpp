#!/bin/bash
# Upload de firefox versie naar ldev.eu.org
# Usage: firefox_upload.sh <session_token> [-d|--debug]

root="https://ldev.eu.org"
ses_token=$1
if [ "$1" = "-d" ] | [ "$1" = "--debug" ] ; then
  echo "debug mode"
  root="http://localhost:80"
  ses_token=$2
fi

TOKEN_GET_URL="$root/sestoken"

if [[ -z "$ses_token" ]] ; then
  echo "Session token required"
  echo "Go to $TOKEN_GET_URL and copy the token here"
  xdg-open $TOKEN_GET_URL
  echo -n "token: "
  read ses_token
  if [[ -z "$ses_token" ]] ; then
    ses_token="$(wl-paste)"
  fi
fi


echo "Deleting old artifacts..."
rm -rf web-ext-artifacts/*
echo "Building..."
web-ext build

ver=$(ls web-ext-artifacts | rg "smartschool_-([0-9]*.[0-9]*.[0-9]*).zip" -r '$1')

echo "version: $ver"
echo "Uploading..."
curl --data-binary @web-ext-artifacts/smartschool_-$ver.zip -H "Cookie:session=$ses_token" "$root/firefox/smpp?v=$ver"
