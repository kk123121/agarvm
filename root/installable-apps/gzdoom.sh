#!/bin/bash

echo "**** install gzdoom ****"
apt update
apt install -y wget
wget https://github.com/coelckers/gzdoom/releases/download/g4.12.2/gzdoom_4.12.2_amd64.deb
apt install -y ./gzdoom_4.12.2_amd64.deb
rm gzdoom_4.12.2_amd64.deb