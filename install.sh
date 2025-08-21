git clone https://github.com/kk123121/AgarVM
cd AgarVM
pip install textual
sleep 2
python3 installer.py
docker build -t AgarVM . --no-cache
cd ..

sudo apt update
sudo apt install -y jq

mkdir Save
cp -r AgarVM/root/config/* Save

json_file="AgarVM/options.json"
if jq ".enablekvm" "$json_file" | grep -q true; then
    docker run -d --name=AgarVM -e PUID=1000 -e PGID=1000 --device=/dev/kvm --security-opt seccomp=unconfined -e TZ=Etc/UTC -e SUBFOLDER=/ -e TITLE=AgarVM -p 3000:3000 --shm-size="2gb" -v $(pwd)/Save:/config --restart unless-stopped AgarVM
else
    docker run -d --name=AgarVM -e PUID=1000 -e PGID=1000 --security-opt seccomp=unconfined -e TZ=Etc/UTC -e SUBFOLDER=/ -e TITLE=AgarVM -p 3000:3000 --shm-size="2gb" -v $(pwd)/Save:/config --restart unless-stopped AgarVM
fi
clear
echo "All finished! Check the port tab in your terminal you used to install this vm!"
