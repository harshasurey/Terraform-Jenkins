terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configuration aws provider
provider "aws" {
  region     = "us-west-1"
  access_key = "AKIA3W4H53SMMCUM45QE"
  secret_key = "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"
}

# Default VPC

data "aws_vpc" "default" {
 default = true
}

# Security Group

resource "aws_security_group" "web_server_sg_tf" {
 name        = "web-server-sg-tf"
 description = "Allow SSH and HTTP"
 vpc_id      = data.aws_vpc.default.id
}

resource "aws_security_group_rule" "allow_SSH" {
 type              = "ingress"
 description       = "SSH ingress"
 from_port         = 22
 to_port           = 22
 protocol          = "tcp"
 cidr_blocks       = ["0.0.0.0/0"]
 security_group_id = aws_security_group.web_server_sg_tf.id
}

resource "aws_security_group_rule" "allow_http" {
 type              = "ingress"
 description       = "HTTP ingress"
 from_port         = 80
 to_port           = 80
 protocol          = "tcp"
 cidr_blocks       = ["0.0.0.0/0"]
 security_group_id = aws_security_group.web_server_sg_tf.id
}

resource "aws_security_group_rule" "allow_all" {
 type              = "ingress"
 description       = "allow all"
 from_port         = 0
 to_port           = 0
 protocol          = "-1"
 cidr_blocks       = ["0.0.0.0/0"]
 security_group_id = aws_security_group.web_server_sg_tf.id
}

#Instance block

resource "aws_instance" "Docker_webserver" {
 ami                         = "ami-081a3b9eded47f0f3"
 instance_type               = "t2.micro"
 key_name                    = "Docker-ssh"
 vpc_security_group_ids      = [aws_security_group.web_server_sg_tf.id]
 associate_public_ip_address = true
 root_block_device {
   volume_type           = "gp2"
   volume_size           = "8"
   delete_on_termination = true
 }
  #user Data
  user_data = <<EOF
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
  
tags = {
    Name = "DOCKER SERVER"
  }
}
