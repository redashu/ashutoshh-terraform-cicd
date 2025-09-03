output "public_Ips" {
    value = aws_instance.example[*].public_ip
  
}

# storing ips 
resource "local_file" "example_ips" {
  content = join("\n",aws_instance.example[*].public_ip)
  filename = "${path.module}/ec2_ips.txt"
  
}

# creating ansible inventory like file 
resource "null_resource" "stop_ipaddress" {
  depends_on = [ aws_instance.example ]
  provisioner "local-exec" {
    command = <<EOT
      echo "[hello]" >ip.txt
      echo "${join("\n",aws_instance.example[*].public_ip)}" >>ip.txt
      EOT   
  }
  
}