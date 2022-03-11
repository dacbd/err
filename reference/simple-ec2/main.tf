terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.2.0"
    }
  }
  required_version = ">= 1.1.6"
}

provider "aws" {
  profile = "default"
  region  = "us-west-2"
  default_tags {
    tags = {
      contact      = "me@example.com"
      created_with = "terraform"
      repo         = "https://github.com/octo-org/my-repo"
    }
  }
}



variable "target_vpc" {
  description = "The VPC the server will be in, ex: vpc-0b10d2394a120e833"
  default = ""
}
variable "target_subnet" {
  description = "The private subnet id for the server to run in. ex: subnet-06ee5a8e940002c2d"
  default = ""
}
variable "target_keypair" {
  description = "The ssh kaypair to be used."
  default = "my-public-key"
}

data "aws_iam_instance_profile" "role" {
  name = "learn-about-role-chaining" 
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"]
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server*"]
  }
  filter {
    name = "owner-id"
    values = ["099720109477"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_instance" "ghar" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"
  key_name      = var.target_keypair
  subnet_id     = var.target_subnet 

  root_block_device {
    volume_type = "standard"
    volume_size = 100
  }

  iam_instance_profile = data.aws_iam_instance_profile.role.name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  tags = {
    Name        = "My_new_server"
    other_tags  = "here"
  }
  metadata_options {
    http_endpoint = "enabled"
    http_tokens = "required"
  }
}

resource "aws_security_group" "allow_ssh" {
  name = "allow_ssh"
  description = "Allow inbound ssh traffic from private subnets"
  vpc_id = var.target_vpc
  ingress = [
    {
      description = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [ "10.0.0.0/8" ]
      ipv6_cidr_blocks = []
      self             = true
      security_groups  = []
      prefix_list_ids  = []
    }, {
      description = "ping"
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      cidr_blocks = [ "10.0.0.0/8" ]
      ipv6_cidr_blocks = []
      self             = true
      security_groups  = []
      prefix_list_ids  = []
    }
  ]
  egress = [
    {
      description = "Allow all outbound traffic"
      from_port = 0
      to_port = 0
      protocol = -1
      cidr_blocks = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      self             = true
      security_groups  = []
      prefix_list_ids  = []
    }
  ]
}
