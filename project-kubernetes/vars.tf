variable "environment" {
  description = "Environment name for deployment"
  type        = string
  default     = "worker-node"
}

variable "instance_type" {
  description = "Worker Nodes"
  type        = string
  default     = "t3.small"
}

# EC2 Variables
variable "ssh_key" {
  description = "ssh key name"
  type        = string
  default     = "my-ssh-key"
}

variable "ec2_user_data" {
  description = "User data shell script for Jenkins EC2"
  type        = string
  default     = <<EOF
#!/bin/bash
yum update -y
yum install -y docker
service docker start
usermod -a -G docker ec2-user
EOF
}
