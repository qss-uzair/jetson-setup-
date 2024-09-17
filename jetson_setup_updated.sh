# create a single partition on the SSD
# Adding FifeSystem to the SSD
sudo mkfs.ext.4 /dev/nvme0n1
# create a mount point
sudo mkdir /mnt/nvme
# mount the SSD
sudo mount /dev/nvme0n1 /mnt/nvme

## now ensure the SSD mounts on boot
# get the UUID of the SSD
sudo blkid
# add the following line to /etc/fstab
sudo nano /etc/fstab
UUID=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX /mnt/nvme ext4 defaults 0 0
#test the fstab
sudo mount -a

# mount SSD
## DO IT THROUGH THE GUI for a linux system

# fix a static IP address for the jetson on your main router
## DO IT IN THE MAIN ROUTER SETTINGS(DHCP CLIENT LIST)


# Get Jetpack 6.0, Riva will work out of the box with it

sudo apt-get update
sudo apt-get install pip nano git-lfs


# jetson-stats
sudo pip install -U jetson-stats
sudo systemctl restart jtop.service
>>jtop

# disable gui:
sudo systemctl set-default multi-user.target
sudo systemctl disable nvargus-daemon.service

# swap, place in HDD, swaps RAM with 'swap' when running out of memory
sudo systemctl disable nvzramconfig
sudo fallocate -l 16G /mnt/ssd/16GB.swap 
sudo mkswap /mnt/ssd/16GB.swap #will give error GPT it `sudo chmod 0600 /mnt/ssd/16GB.swap` -> ls -l `/mnt/ssd/16GB.swap` ->  `sudo swapon /mnt/ssd/16GB.swap`
sudo swapon /mnt/ssd/16GB.swap 
sudo nano /etc/fstab 
/mnt/ssd/16GB.swap none swap sw 0 0 
sudo mount -a
sudo swapoff -a
sudo swapon -a
sudo reboot 
swapon --show

(swap should appear)

# activate cpus: [!!NOT GOING ON MAX POWER AFTER REBOOT]
(refrence : https://developer.ridgerun.com/wiki/index.php/NVIDIA_Jetson_Orin/JetPack_5.0.2/Performance_Tuning/Maximizing_Performance)
sudo su
echo 1 > /sys/devices/system/cpu/cpu4/online
echo 1 > /sys/devices/system/cpu/cpu5/online
echo 1 > /sys/devices/system/cpu/cpu6/online
echo 1 > /sys/devices/system/cpu/cpu7/online
echo 1 > /sys/devices/system/cpu/cpu8/online
echo 1 > /sys/devices/system/cpu/cpu9/online
echo 1 > /sys/devices/system/cpu/cpu10/online
echo 1 > /sys/devices/system/cpu/cpu11/online

# Max power mode



# max performance:
## This ensures the Jetson runs at maximum performance 
(refrence: https://forums.developer.nvidia.com/t/how-to-maximize-deeplearning-performance-of-jetson-orin/265426)
sudo nano /etc/systemd/system/jetsonClocks.service

[Unit]
Description=Jetson Clocks
After=nvpmodel.service

[Service]
Type=oneshot
ExecStart=/bin/bash -c /usr/bin/jetson_clocks

[Install]
WantedBy=multi-user.target

sudo chmod 644 /etc/systemd/system/jetsonClocks.service
sudo systemctl daemon-reload
sudo systemctl enable jetsonClocks.service
sudo reboot


# update again
sudo apt update
sudo apt upgrade
sudo reboot

# setup the default store volumes for docker containers
## source: https://github.com/dusty-nv/jetson-inference/blob/master/docs/aux-docker.md

# riva
1. create ngc acct
NEW-QSS-Key : ODlydTcxMzZmZmhzNWpnMWQzNG5iOXQxYjI6MGZkZGYxYWMtZjAzMC00MDM2LTgyYTktMDkzMTQ3NGE4Njcy

2. 
cd ~ && mkdir ngc_setup && cd ngc_setup
wget --content-disposition https://api.ngc.nvidia.com/v2/resources/nvidia/ngc-apps/ngc_cli/versions/3.42.0/files/ngccli_arm64.zip -O ngccli_arm64.zip && unzip ngccli_arm64.zip
chmod u+x ngc-cli/ngc
echo "export PATH=\"\$PATH:$(pwd)/ngc-cli\"" >> ~/.bash_profile && source ~/.bash_profile
ngc config set


ngc registry resource download-version nvidia/riva/riva_quickstart_arm64:2.15.1
cd riva_quickstart_arm64:2.15.1 # or the directory that is created
nano config.sh # set false for services not in use, add more languages to the asr languages ex:"en-US ar-SA" 
sudo bash riva_init.sh
bash riva_start.sh 

Install RIVA Python Client:
https://jetsonhacks.com/2023/08/07/speech-ai-on-nvidia-jetson-tutorial/
# would need to pass in the sample rate 44,000 along with the mic to make it work for .../Scripts/ASR/transcribe_mic.py



# Setup for LLM + TTS
## LLM
### download the image for nano LLM with proper CUDA and Torch Support

### build the container

### attach to the contaier

### To setup the LLM, build the wheel from the source file for 


## TTS













# running containers
sudo docker run --runtime nvidia -it  --network=host dustynv/local_llm:r35.4.1
# and similar for mlc container if the local_llm doesn't work

# running the MLC
https://github.com/dusty-nv/jetson-containers/tree/master/packages/llm/mlc



ln -s $(huggingface-downloader daryl149/llama-2-7b-chat-hf) /data/models/mlc/dist/models/Llama-2-7b-chat-hf
python3 -m mlc_llm.build \
    --model Llama-2-7b-chat-hf \
    --quantization q4f16_ft \
    --artifact-path /data/models/mlc/dist \
    --max-seq-len 4096 \
    --target cuda \
    --use-cuda-graph \
    --use-flash-attn-mqa

