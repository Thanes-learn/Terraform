provider "aws" {
  region = "us-east-2"
}

# Creating Access Control list to control Network 
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

# Like templete to launch EC2 instance with Human interaction and assign to ELB
resource "aws_launch_configuration" "launchConfig" {
  image_id        = "ami-077e31c4939f6a2f3"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.webSecurity.id]
  key_name = "adminSSH"
  user_data       = <<EOF
  #!/bin/bash
	yum -y update
	yum -y install openssl
	useradd monitor -G wheel
  echo "admin@123" | passwd --stdin monitor
  sed -i "s/.*PasswordAuthentication.*/PasswordAuthentication yes/g" /etc/ssh/sshd_config
  service restart sshd
  service sshd restart
  yum -y install httpd
  MYIP=$HOSTNAME
  echo "<h1>Hello World</h1><h2>  $HOSTNAME    $DATE </h1> ">/var/www/html/index.html
  service httpd start
  service httpd enabled
  service sshd restart
  chkconfih httpd on
  EOF

# Create new instance before terminating old instance-- 
#Otherwise chance to lost connectivity
  lifecycle {
    create_before_destroy = true
  }


}

# Display all available Zone
#If not specified zone, system will select randomly 
data "aws_availability_zones" "all" {}


#Access Contrl list for Load balancer
resource "aws_security_group" "elb" {
  name = "elb Security group"  
  
  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }  
  
  # Inbound HTTP from anywhere

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Not Suitable here because i didnt configure SSL/CERT
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Create and configure load balance to distribute traffic
resource "aws_elb" "elasticlb" {
  name               = "elasitc load balaence"
  security_groups    = [aws_security_group.elb.id]
  availability_zones = data.aws_availability_zones.all.names 
  
  # ELB Health Check
  health_check {
    target              = "HTTP:${80}/"
    interval            = 30
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
   # listener for incoming HTTP requests.
  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = 80
    instance_protocol = "http"
  }
}

# Create Auto scalling feature 
resource "aws_autoscaling_group" "mutipleServer" {
  launch_configuration = aws_launch_configuration.launchConfig.id
  availability_zones   = data.aws_availability_zones.all.names
  min_size             = 2
  max_size             = 10

  # when new instance initiated, It will assign to this below load balance 

  load_balancers    = [aws_elb.elasticlb.name]
  health_check_type = "ELB"

  tag {
    key                 = "Name"
    value               = "Auto Scaling Configration"
    propagate_at_launch = true
  }

}

# Auto dowm Instance capasity daily 5pm
resource "aws_autoscaling_schedule" "scale_down" {
  scheduled_action_name  = "scale_down"
  min_size               = 2
  max_size               = 3
  recurrence             = "0 17 * * *"
  desired_capacity       = 2
  autoscaling_group_name = [aws_autoscaling_group.mutipleServer.name]
}

# Auto up  Instance capasity daily 9am
resource "aws_autoscaling_schedule" "scale_up" {
  scheduled_action_name  = "scale_up"
  min_size               = 1
  max_size               = 10
  recurrence             = "* 09 * * *"
  desired_capacity       = 5
  autoscaling_group_name = [aws_autoscaling_group.mutipleServer.name]
}


#Display DNS URL to check web server--
#We can use this DNS to mapping with another readable hostname with route53 
output "clb_dns_name" {
  value       = aws_elb.example.dns_name
  description = "The domain name of the load balancer"
}