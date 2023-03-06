# This file references the resources and sets the necessary variables.
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "vpc_tag" {
  description = "Tag for the VPC"
  default     = "my-vpc"
}

variable "subnet_cidr" {
  description = "CIDR block for the subnet"
  default     = "10.0.0.0/24"
}

variable "subnet_tag" {
  description = "Tag for the subnet"
  default     = "my-subnet"
}

variable "internet_gateway_tag" {
  description = "Tag for the Internet Gateway"
  default     = "my-igw"
}

variable "ec2_role_name" {
  description = "Name of the EC2 instance role"
  default     = "ec2_role"
}

variable "ec2_instance_profile_name" {
  description = "Name of the EC2 instance profile"
  default     = "ec2_instance_profile"
}

variable "ec2_role_policy_name" {
  description = "Name of the policy attached to the EC2 instance role"
  default     = "ec2_role_policy"
}

variable "ec2-trust-policy" {
  description = "Name of the JSON file containing the trust policy for the EC2 instance role"
  default     = "trust-policy.json"
}

variable "ec2-s3-permissions" {
  description = "Name of the JSON file containing the S3 bucket permissions for the EC2 instance role"
  default     = "s3-permissions.json"
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  default     = "rayblackteam"
}

variable "security_group_name" {
  description = "Name of the security group"
  default     = "my-security-group"
}

variable "ami" {
  description = "AMI ID for the EC2 instance"
  default     = "ami-0dfcb1ef8550277af"
}

variable "instance_type" {
  description = "Type of the EC2 instance"
  default     = "t2.micro"
}

variable "ssh_key_name" {
  description = "Name of the SSH key pair"
  default     = "MyNewKeyPair"
}

variable "ec2_user_data" {
  description = "User data script for EC2 instances"
  type        = string
  default     = <<EOF
#!/bin/bash
# Install Jenkins and Java
sudo wget -O /etc/yum.repos.d/jenkins.repo \\
    <https://pkg.jenkins.io/redhat-stable/jenkins.repo>
sudo rpm --import <https://pkg.jenkins.io/redhat-stable/jenkins.io.key>
sudo yum -y upgrade
# Add required dependencies for the jenkins package
sudo amazon-linux-extras install -y java-openjdk11
sudo yum install -y jenkins
sudo systemctl daemon-reload

# Start Jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Firewall Rules
if [[ $(firewall-cmd --state) = 'running' ]]; then
    YOURPORT=8080
    PERM="--permanent"
    SERV="$PERM --service=jenkins"

    firewall-cmd $PERM --new-service=jenkins
    firewall-cmd $SERV --set-short="Jenkins ports"
    firewall-cmd $SERV --set-description="Jenkins port exceptions"
    firewall-cmd $SERV --add-port=$YOURPORT/tcp
    firewall-cmd $PERM --add-service=jenkins
    firewall-cmd --zone=public --add-service=http --permanent
    firewall-cmd --reload
fi
EOF
}

variable "ec2_tag" {
  description = "Tag for the EC2 instance"
  default     = "jenkins-server"
}

variable "dynamo_table_name" {
  description = "Table Name for  EC2 instance access"
  default = "MyTable"
}

variable "dynamodb_tag" {
  default = "dynamodb-table"
}

variable "dynamodb_env" {
  default = "test"
}