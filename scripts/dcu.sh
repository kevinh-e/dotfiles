#!/bin/bash

curl -L "https://discord.com/api/download?platform=linux" -o "./dc.deb"
sudo dpkg -i "./dc.deb"

rm -rf "dc.deb"

sh -c "$(curl -sS https://raw.githubusercontent.com/Vendicated/VencordInstaller/main/install.sh)"
