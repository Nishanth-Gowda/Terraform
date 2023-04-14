output "ec2_remote_access" {
  description = "EC2 Remote Access"
  value       = "ssh -i /path/to/my/private_key.pem ec2-user@${element(aws_instance.worker_node.*.public_ip, 0)}"
}
output "instance_public_ip" {
  description = "Public IP address of the Kubernetes worker instance"
  value       = "Worker Node Public IPs: ${join(", ", [for instance in aws_instance.worker_node : instance.public_ip])}"
}