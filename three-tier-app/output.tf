output "vpc_id" {
  value = aws_vpc.dhruv_vpc.id
}

output "webserver1_public_ip" {
  description = "The public IP address of Web Server 1"
  value       = aws_instance.ec2_instance[0].public_ip
}

output "webserver2_public_ip" {
  description = "The public IP address of Web Server 2"
  value       = aws_instance.ec2_instance[1].public_ip
}