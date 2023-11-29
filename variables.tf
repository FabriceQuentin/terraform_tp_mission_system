variable "aws_region" {
  
  type        = string
  default     = "eu-west-1"
  
}

variable "vpc-cidr" {
  
  type        = string
  default     = "10.0.0.0/16"
  
}

variable "subnet_public_cidr" {
  
  type        = string
  default     = "10.0.1.0/24"
  
}

variable "subnet_private_cidr" {
  
  type        = string
  default     = "10.0.2.0/24"
  
}


variable "type_instance" {
  
  type        = string
  default     = "t2.micro"
  
}
