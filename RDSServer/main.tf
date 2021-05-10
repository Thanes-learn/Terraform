provider "aws" {
  region = "us-east-2"
}


#Security Group for Allowing traffic for web
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

#RDS configration
resource "aws_db_instance" "mydb" {
  allocated_storage        = 10 # gigabytes
  engine                   = "mysql"
  engine_version       = "5.7"
  identifier               = "mydb"
  instance_class           = "db.t2.micro"
  name                     = "mydb"
  password                 = "rtsawsadmin"
  port                     = 3306
  publicly_accessible      = true
  username                 = "admin"
  vpc_security_group_ids   = [aws_security_group.webSecurity.id]
}

output "address" {
  value       = aws_db_instance.mydb.address
  description = "Connect to the database at this endpoint"
}
