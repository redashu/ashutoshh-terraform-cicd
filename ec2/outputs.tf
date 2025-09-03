output "public_Ips" {
    value = aws_instance.example[*].public_ip
  
}

# storing ips 
resource "local_file" "example_ips" {
  content = join("\n",aws_instance.example[*].public_ip)
  filename = "${path.module}/ec2_ips.txt"
  
}