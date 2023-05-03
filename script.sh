#!/bin/bash
sudo apt-get update
sudo apt-get install docker.io -y
sudo service docker start
sudo docker pull httpd
sudo docker images
sudo docker run -itd --name facebook -p "8010:80" httpd
