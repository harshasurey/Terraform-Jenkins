#!/bin/bash
sudo apt-get update
sudo apt-get install docker.io -y
sudo docker pull httpd
docker images
docker run -itd --name facebook -p "8010:80" httpd
