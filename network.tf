resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc-cidr
tags = {
   Name = "my_vpc"
  }
}

resource "aws_subnet" "my_private_subnet" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = var.subnet_private_cidr
  #availability_zone = "eu-west-1a"
  tags = {
    Name = "tf-example-subnet-private"
  }
}

resource "aws_subnet" "my_public_subnet" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = var.subnet_public_cidr
  #availability_zone = "eu-west-1a"
  tags = {
    Name = "tf-example-subnet-public"
  }
}


resource "aws_internet_gateway" "my_ig" {
   vpc_id = aws_vpc.my_vpc.id
   tags = {
     Name = "my_Gateway"
   }
}

resource "aws_route_table" "my_public_route_table" {
   vpc_id = aws_vpc.my_vpc.id
   
   route {
     cidr_block = "0.0.0.0/0"
     gateway_id = aws_internet_gateway.my_ig.id
   }

   tags = {
     Name = "tf-public-routetable"
   }
}

resource "aws_route_table_association" "public_1_rt_a" {
 subnet_id = aws_subnet.my_public_subnet.id
 route_table_id = aws_route_table.my_public_route_table
}



#Creation ressource aws NAT
resource "aws_nat_gateway" "my_nat_gateway" {
  allocation_id = aws_eip.elastic.id
  subnet_id     = aws_subnet.my_public_subnet.id

  

  tags = {
    Name = "my_nat_gateway"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.my_ig]
}

#creation dune elastic ip
resource "aws_eip" "elastic" {
  instance = aws_instance.my_nat_gateway.id  #machine EC2
  domain   = "vpc"
}

# recupere l'ip publique et l'associe à la NAT
output "nat_eip_public_ip" {
       value = aws_eip.nat_eip_public_ip
}

#output "nat_eip_public_ip" {   value = aws_eip.nat_eip.public_ip }



# route table private
resource "aws_route_table" "my_private_route_table" {
   vpc_id = aws_vpc.my_vpc.id
   
   route {
     cidr_block = "0.0.0.0/0"
     gateway_id = aws_internet_gateway.my_ig.id
   }

   tags = {
     Name = "tf-private-routetable"
   }
}

# Association entre notre route table private et notre private subnet
resource "aws_route_table_association" "private_1_rt_a" {
 subnet_id = aws_subnet.my_private_subnet.id
 route_table_id = aws_route_table.my_private_route_table.id
}



#creation d'un groupe de securite

resource "aws_security_group" "my_sg" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.my_vpc.id 

  ingress {
    description      = "tls from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.my_vpc.cidr_block]
    #ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  egress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "my_sg"
  }
}


# Ec2 public network
resource "aws_instance" "my_ec2" {
  ami = "ami-0694d931cee176e7d"
  instance_type = var.type_instance
  subnet_id = aws_subnet.my_public_subnet.id 
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
