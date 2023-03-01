terraform {
  #############################################################
  ## AFTER RUNNING TERRAFORM APPLY (WITH LOCAL BACKEND)
  ## YOU WILL UNCOMMENT THIS CODE THEN RERUN TERRAFORM INIT
  ## TO SWITCH FROM LOCAL BACKEND TO REMOTE AWS BACKEND
  #############################################################
   backend "s3" {
    bucket         = "ec2-provisioned-terraform-state" # REPLACE WITH YOUR BUCKET NAME
    key            = "project-1/import-bootstrap/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-atomic-lock-for-backend"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
}

provider "aws"{
    region = "us-east-1"
}

resource "aws_instance" "MyWebServer-1" {
    ami = "ami-0557a15b87f6559cf" #Canonical, Ubuntu, 22.04 LTS,
    instance_type = "t2.micro"
    security_groups = [aws_security_group.instances.name]
    user_data = <<-EOF
            #!/bin/bash
            echo "<h1> Hello World from $(hostname -f)</h1>" > index.html
            python3 -m http.server 8080 &
            EOF
  
}

resource "aws_instance" "MyWebServer-2" {
    ami = "ami-0557a15b87f6559cf"
    instance_type = "t2.micro"
    security_groups = [aws_security_group.instances.name]
    user_data = <<-EOF
            #!/bin/bash
            echo "Hello World from $(hostname -f)" > index.html
            python3 -m http.server 8080 &
            EOF
}
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet" "default_subnet" {
  vpc_id = data.aws_vpc.default.id
  cidr_block = "172.31.16.0/20"
}

resource "aws_security_group" "instances" {
  name = "instance_security_group"
}

resource "aws_security_group_rule" "allow_http_inbound" {
  type = "ingress"
  security_group_id = aws_security_group.instances.id
  from_port = 8080
  to_port = 8080
  protocol = "tcp"
  cidr_blocks = [ "0.0.0.0/0" ]
}

resource "aws_security_group_rule" "allow_ssh" {
  type = "ingress"
  security_group_id = aws_security_group.instances.id
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = [ "0.0.0.0/0" ]
}

resource "aws_lb" "load_balancer" {
  name = "my-app-alb"
  load_balancer_type = "application"
  subnets = [ "data.aws_subnet.default_subnet.id" ]
  security_groups = [ aws_security_group.alb.id ]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port = 80
  protocol = "HTTP"

  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

resource "aws_lb_target_group" "instances" {
  name = "my-target-group"
  port = 8080
  protocol = "HTTP"
  vpc_id = data.aws_vpc.default.id
  
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "MyWebServer-1" {
  target_group_arn = aws_lb_target_group.instances.arn
  target_id = aws_instance.MyWebServer-1.id
  port = 8080
}

resource "aws_lb_target_group_attachment" "MyWebServer-2" {
  target_group_arn = aws_lb_target_group.instances.arn
  target_id = aws_instance.MyWebServer-2.id
  port = 8080
}

resource "aws_lb_listener_rule" "instances" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.instances.arn
  }
}

resource "aws_security_group" "alb" {
  name = "alb-security-group"
}

resource "aws_security_group_rule" "allow_alb_http_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.alb.id

  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

}

resource "aws_security_group_rule" "allow_alb_all_outbound" {
  type              = "egress"
  security_group_id = aws_security_group.alb.id

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

}


resource "aws_db_instance" "db_instance" {
  allocated_storage = 20
  # This allows any minor version within the major engine_version
  # defined below, but will also result in allowing AWS to auto
  # upgrade the minor version of your DB. This may be too risky
  # in a real production environment.
  auto_minor_version_upgrade = true
  storage_type               = "standard"
  engine                     = "postgres"
  engine_version             = "12"
  instance_class             = "db.t2.micro"
  db_name                    = "mydb"
  username                   = "foo"
  password                   = "foobarbaz"
  skip_final_snapshot        = true
}