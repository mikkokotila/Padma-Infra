MIKKOKOTILA_TOKEN=$1

sudo apt-get update -y
sudo apt install unzip

# install and configure nginx
sudo apt-get install nginx -y

curl https://raw.githubusercontent.com/mikkokotila/Padma-Infra/master/Padma-API.conf > Padma-API.conf
curl https://raw.githubusercontent.com/mikkokotila/Padma-Infra/master/Padma-Frontend.conf > Padma-Frontend.conf

sudo mv Padma-API.conf /etc/nginx/sites-enabled/Padma-API.conf
sudo mv Padma-Frontend.conf /etc/nginx/sites-enabled/Padma-Frontend.conf
sudo nginx -s reload

# download and unpack data
wget -qq --show-progress https://goo.gl/GyTv7n -O /tmp/dictionaries.zip
sudo unzip -qq -o /tmp/dictionaries.zip -d /home/ubuntu/Padma-Data

wget -qq --show-progress https://github.com/mikkokotila/Rinchen-Terdzo-Tokenized/raw/master/docs/docs.zip -O /tmp/docs.zip
sudo unzip -qq -o /tmp/docs.zip -d /home/ubuntu/Padma-Data/docs/

wget -qq --show-progress https://github.com/mikkokotila/Rinchen-Terdzo-Tokenized/raw/master/tokens/tokens.zip -O /tmp/tokens.zip
sudo unzip -qq -o /tmp/tokens.zip -d /home/ubuntu/Padma-Data/tokens/

# setup and run docker
sudo apt-get install \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg-agent \
  software-properties-common -y

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo apt-key fingerprint 0EBFCD88

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get update -y
sudo apt-get install docker-ce docker-ce-cli containerd.io -y
sudo docker login docker.pkg.github.com --username mikkokotila --password $MIKKOKOTILA_TOKEN

# run Padma-API
sudo docker pull docker.pkg.github.com/mikkokotila/padma/core_api:master
NEW_IMAGE_ID=$(sudo docker images | grep core_api | grep master | tail -1 | tr -s ' ' | cut -d ' ' -f3)
sudo docker -m 6000m run --restart unless-stopped -v /home/ubuntu/Padma-Data:/tmp --name Padma-API -p 5000:5000 --detach $NEW_IMAGE_ID;

# run Padma-Frontend
sudo docker pull docker.pkg.github.com/mikkokotila/padma-frontend/frontend:master
NEW_IMAGE_ID=$(sudo docker images | grep frontend | grep master | tail -1 | tr -s ' ' | cut -d ' ' -f3)
sudo docker run -m 6000m --restart unless-stopped -p 8080:8080 --detach $NEW_IMAGE_ID;
