variable "ami_id" {
  type    = string
  default = "ami-086f060214da77a16"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "region_name" {
  type    = string
  default = "us-west-2"
}

variable "vpc_cidr" {
  type    = string
  default = "10.20.0.0/16"
}

variable "subnet_cidr" {
  type    = string
  default = "10.20.0.0/24"
}

variable "subnet2_cidr" {
  type    = string
  default = "10.20.1.0/24"
}

variable "az1" {
  type    = string
  default = "us-west-2a"
}

variable "az2" {
  type    = string
  default = "us-west-2b"
}



