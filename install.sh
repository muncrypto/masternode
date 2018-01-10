#!/bin/bash
sudo touch /var/swap.img
sudo chmod 600 /var/swap.img
sudo dd if=/dev/zero of=/var/swap.img bs=1024k count=2000
mkswap /var/swap.img
sudo swapon /var/swap.img
sudo echo "/var/swap.img none swap sw 0 0" >> /etc/fstab
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get dist-upgrade -y
sudo apt-get install -y nano htop git build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils software-properties-common libboost-all-dev
sudo add-apt-repository -y ppa:bitcoin/bitcoin
sudo apt-get update -y
sudo apt-get install -y libdb4.8-dev libdb4.8++-dev
mkdir ~/temp
git clone https://github.com/muncrypto/muncoin ~/temp
cd ~/temp
./autogen.sh
./configure
make
make install
cd
mkdir ~/muncore
mkdir ~/.muncore
cp ~/temp/src/mund ~/muncore
cp ~/temp/src/mun-cli ~/muncore
sudo apt-get install -y pwgen
GEN_PASS=$(pwgen -1 -n 20)
echo -e "rpcuser=muncoinuser\nrpcpassword=${GEN_PASS}\nrpcport=12547\nport=12548\nlisten=1\nmaxconnections=256" >> ~/.muncore/mun.conf
cd ~/muncore
./mund -daemon
sleep 10
masternodekey=$(./mun-cli masternode genkey)
./mun-cli stop
echo -e "masternode=1\nmasternodeprivkey=$masternodekey" >> ~/.muncore/mun.conf
./mund -daemon
cd ~/.muncore
sudo apt-get install -y python-virtualenv
git clone https://github.com/muncrypto/sentinel.git
cd sentinel
virtualenv ./venv
./venv/bin/pip install -r requirements.txt
#sudo echo "muncoin_conf=~/.muncore/mun.conf" >> ~/.muncore/sentinel/sentinel.conf
sudo crontab -l >> tempcron
sudo echo "* * * * * cd ~/.muncoin/sentinel && ./venv/bin/python bin/sentinel.py 2>&1 >> sentinel-cron.log" >> tempcron
sudo crontab tempcron
rm tempcron
echo "Masternode private key: $masternodekey"
echo "Job completed successfully" 
