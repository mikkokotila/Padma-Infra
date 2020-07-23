sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get dist-upgrade -y
sudo apt-get install nginx -y

sudo systemctl nginx stop
sudo sed "s/_IP_/$IP/" nginx.conf > /etc/nginx/nginx.conf
sudo systemctl nginx start

sudo cat /etc/nginx/nginx.conf

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

sudo docker login docker.pkg.github.com --username mikkokotila --password ${{ secrets.MIKKOKOTILA_TOKEN }}
sudo docker pull docker.pkg.github.com/mikkokotila/padma/core_api:master
NEW_IMAGE_ID=$(sudo docker images | grep core_api | tail -1 | tr -s ' ' | cut -d ' ' -f3)
sudo docker stop $CURRENT_IMAGE_ID
sudo docker run --restart unless-stopped -p 5000:5000 $NEW_IMAGE_ID
echo $NEW_IMAGE_ID > current_image_id.txt
