#!/bin/bash
set -x
cd /srv/minecraft


VH2_URL="https://media.forgecdn.net/files/3283/29/Valhelsia_2-2.3.3-SERVER.zip"
#curl -Ls "$VH2_URL" -o Valhelsia_2-SERVER.zip

#unzip Valhelsia_2-SERVER.zip

forge_binary=""
for forge in forge-*-installer.jar; do
  if [ "$forge" -nt "$forge_binary" ]; then
    forge_binary=$forge
  fi
done

java -jar $forge_binary --installServer
rm $forge_binary
rm Valhelsia_2.zip
