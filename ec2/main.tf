# RSA key of size 4096 bits
resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# use above to put public in ec2 
resource "aws_key_pair" "example" {
  key_name = "${var.aws-instance-name}-key"
  #public_key = file("/home/ec2-user/.ssh/ashu-key.pub")
  public_key = tls_private_key.example.public_key_openssh
  depends_on = [ tls_private_key.example ]
  
}

# incase you want to save private key as well
resource "local_file" "ashu-private-key" {
  content  = tls_private_key.example.private_key_pem
  filename = "${path.module}/ashu-privateKey.pem"
  file_permission = "0400"
  depends_on = [ aws_key_pair.example ]
}

# security group 
resource "aws_security_group" "allow_tls" {
  name        = var.securitygroup
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = data.aws_vpc.example.id

  tags = {
    Name = "ashu-security-groupnew"
  }
}
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = data.aws_vpc.example.cidr_block
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv480" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = data.aws_vpc.example.cidr_block
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv422" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = data.aws_vpc.example.cidr_block
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}


resource "aws_instance" "example" {
  ami = var.ami
  instance_type = var.type
  vpc_security_group_ids = [aws_security_group.allow_tls.id]
  count = var.instance-number
  tags = {
    Name = "${var.aws-instance-name}-${count.index}"
  }
  key_name = aws_key_pair.example.key_name
  depends_on = [ aws_key_pair.example,aws_security_group.allow_tls ]
  
}