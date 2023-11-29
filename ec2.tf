# Ec2 public network
resource "aws_instance" "my_ec2" {
  ami = "ami-0694d931cee176e7d"
  instance_type = var.type_instance
  subnet_id = aws_subnet.my_public_subnet
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  ebs_block_device {
     device_name = "/dev/sda1"
     encrypted = true
     volume_size = 30
     delete_on_termination = true
  }

  tags = {
    Name = "my_ec2_terraform"
  }
}


# EC2 private network
resource "aws_instance" "my_ec2" {
  ami = "ami-0694d931cee176e7d"
  instance_type = var.type_instance
  subnet_id = aws_subnet.my_private_subnet.id 
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  ebs_block_device {
     device_name = "/dev/sda1"
     encrypted = true
     volume_size = 30
     delete_on_termination = true
  }

  tags = {
    Name = "my_ec2_terraform"
  }
}
