#Specifying the use of default VPC
resource "aws_default_vpc" "default" {
  tags = {
    Name = "default-vpc"
  }
}

# Create EC2 Security Group and Security Rules
resource "aws_security_group" "worker_security_group" {
  name        = "${var.environment}-security-group"
  description = "Apply to Kubernetes Worker SG"

  ingress {
    description = "SSH access from a specific source"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # replace X.X.X.X with your IP address or range
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-security-group"
  }
}

# Create SSH Keys for EC2 Remote Access
resource "tls_private_key" "generated" {
  algorithm = "RSA"
}
resource "local_file" "private_key_pem" {
  content         = tls_private_key.generated.private_key_pem
  filename        = "${var.ssh_key}.pem"
  file_permission = "0400"
}
resource "aws_key_pair" "generated" {
  key_name   = var.ssh_key
  public_key = tls_private_key.generated.public_key_openssh
}

#Creating the EC2 Instance
resource "aws_instance" "worker_node" {
  ami                  = "ami-06e46074ae430fba6"
  instance_type        = var.instance_type
  key_name             = aws_key_pair.generated.key_name
  vpc_security_group_ids  = [aws_security_group.worker_security_group.id]
  user_data            = var.ec2_user_data
  count                = 2
  connection {
    user        = "ec2-user"
    private_key = tls_private_key.generated.private_key_pem
    host        = self.public_ip
  }
  tags = {
    Name = "kubernetes-${var.environment}"
  }
}

