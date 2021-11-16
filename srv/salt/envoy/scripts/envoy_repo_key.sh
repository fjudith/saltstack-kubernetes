#!/usr/bin/env bash

curl -sL 'https://deb.dl.getenvoy.io/public/gpg.8115BA8E629CC074.key' \
| sudo gpg --dearmor -o /usr/share/keyrings/getenvoy-keyring.gpg