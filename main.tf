provider "aws" {
  region = "us-east-2"
}
resource "aws_instance" "web" {
  ami                    = "ami-077e31c4939f6a2f3"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.webSecurity.id]
  key_name = "adminSSH"
 user_data       = <<EOF
    #!/bin/bash
	yum -y update
	yum -y install openssl
	useradd monitor -G wheel
  echo "admin@123" | passwd --stdin monitor
  sed -i "s/.*PasswordAuthentication.*/PasswordAuthentication yes/g" /etc/ssh/sshd_config
  systemctl stop sshd
  sleep 10
  systemctl start sshd
    yum -y install httpd
    MYIP=$HOSTNAME
    echo "<h1>Hello World</h1><h2>  $HOSTNAME  </h1> ">/var/www/html/index.html
    service httpd start
    service httpd enabled
    chkconfih httpd on
    EOF

  tags = {
    Name  = "webserver built by thanesh"
    Owner = "Thanesh"
  }



}
resource "aws_security_group" "webSecurity" {
  name = "WebServerACL"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

 
 

    ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name  = "webserver SG built by thanesh"
    Owner = "Thanesh"
  }
  
}

output "webinstance_ip" {
  description = "List of IDs of instances"
  value       = aws_instance.web.public_ip
}