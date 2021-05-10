provider "aws" {
  region = "us-east-2"
}


#Security Group for Allowing traffic
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
  ingress {
    from_port   = 3306
    to_port     = 3306
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
#Web Server Configration
resource "aws_instance" "web" {
  ami                    = "ami-077e31c4939f6a2f3"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.webSecurity.id]
  key_name = "adminSSH"
 user_data       = <<EOF
    #!/bin/bash
	yum -y update
	yum -y install openssl
	useradd -p $(openssl passwd -1 admin@123) admin
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



#RDS configration
resource "aws_db_instance" "mydb" {
  allocated_storage        = 10 # gigabytes
  engine                   = "mysql"
  identifier               = "mydb"
  instance_class           = "db.t2.micro"
  name                     = "mydb"
  password                 = "admin@123"
  port                     = 3306
  publicly_accessible      = true
  username                 = "admin"
  vpc_security_group_ids   = [aws_security_group.webSecurity.id]
}

output "address" {
  value       = aws_db_instance.mydb.address
  description = "Connect to the database at this endpoint"
}

output "port" {
  value       = aws_db_instance.mydb.port
  description = "The port the database is listening on"
}
