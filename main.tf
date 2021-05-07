provider "aws" {
  region = "us-east-2"
}
resource "aws_launch_configuration" "launchConfig" {
  image_id        = "ami-077e31c4939f6a2f3"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.webSecurity.id]
  user_data       = <<EOF
    #!/bin/bash
    yum -y update
    yum -y install httpd
    MYIP=$HOSTNAME
    echo "<h1>Hello World</h1><h2>  $HOSTNAME  </h1> ">/var/www/html/index.html
    service httpd start
    service httpd enabled
    chkconfih httpd on
    EOF

  lifecycle {
    create_before_destroy = true
  }


}
resource "aws_autoscaling_group" "mutipleServer" {
  launch_configuration = aws_launch_configuration.launchConfig.name
  availability_zones   = data.aws_availability_zones.all.names
  min_size             = 2
  max_size             = 2

  tag {
    key                 = "Name"
    value               = "launch Configration"
    propagate_at_launch = true
  }

  

}

data "aws_availability_zones" "all" {}


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
