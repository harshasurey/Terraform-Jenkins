#!/bin/sh
export PATH=/usr/local/bin:$PATH;
yum update
yum install docker -y
service docker start
docker login --username="surey" --password="Surendar123@" --email="surendarsurya72@gmail.com"
mv /root/.dockercfg /home/ec2-user/.dockercfg
chown ec2-user:ec2-user /home/ec2-user/.dockercfg
usermod -a -G docker ec2-user
curl -L https://github.com/docker/compose/releases/download/1.7.1/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
chown root:docker /usr/local/bin/docker-compose
cat <<EOF >/home/ec2-user/docker-compose.yml
nginx:
  image: nginx
  ports:
    - "80:80"
EOF
chown ec2-user:ec2-user /home/ec2-user/docker-compose.yml
/usr/local/bin/docker-compose -f /home/ec2-user/docker-compose.yml up -d
