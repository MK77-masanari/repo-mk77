Skip to content
Search or jump to…
Pull requests
Issues
Codespaces
Marketplace
Explore
 
@MK77-masanari 
team-buta
/
VPC-test
Internal
Code
Issues
Pull requests
Actions
Projects
Wiki
Security
Insights
Settings
VPC-test/kiriyama.tf
@MK77-masanari
MK77-masanari etc vpc-name chenge
Latest commit 6a45091 1 hour ago
 History
 1 contributor
110 lines (100 sloc)  2.56 KB

# ---------------------------
# vpc
# ---------------------------
variable "aws_access_key" {}
variable "aws_secret_key" {}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region = "ap-northeast-3"
}
resource "aws_vpc" "buta-vpc" {
  cidr_block = "10.0.4.0/24"
  tags = {
    Name = "buta-vpc"
  }
}

# ---------------------------
# Subnet
# ---------------------------
resource "aws_subnet" "mk77-public-1a-sn" {
  vpc_id            = aws_vpc.buta-vpc.id
  cidr_block        = "10.0.4.0/27"
  availability_zone = "ap-northeast-3a"

  tags = {
    Name = "mk77-public-1a-sn"
  }
}

# ---------------------------
# Internet Gateway
# ---------------------------
resource "aws_internet_gateway" "mk77-igw" {
  vpc_id            = aws_vpc.buta-vpc.id
  tags = {
    Name = "mk77-igw"
  }
}

# ---------------------------
# Route table
# ---------------------------
# Route table作成
resource "aws_route_table" "mk77-public-rt" {
  vpc_id            = aws_vpc.mk77-vpc.id
  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = aws_internet_gateway.mk77-igw.id
  }
  tags = {
    Name = "mk77-public-rt"
  }
}

# SubnetとRoute tableの関連付け
resource "aws_route_table_association" "mk77-public-rt-associate" {
  subnet_id      = aws_subnet.mk77-public-1a-sn.id
  route_table_id = aws_route_table.mk77-public-rt.id
}

#----------------------------------------
# セキュリティグループの作成
#----------------------------------------
resource "aws_security_group" "mk77-sg" {
  name   = "mk77-sg"
  vpc_id = aws_vpc.buta-vpc.id
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---------------------------
# EC2 Key pair
# ---------------------------
variable "key_name" {
  default = "mk77-keypair"
}

# 秘密鍵のアルゴリズム設定
resource "tls_private_key" "mk77-private-key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# ---------------------------
# EC2作成
# ---------------------------
resource "aws_instance" "mk77_ec2"{
  ami                         = data.aws_ssm_parameter.ami-0ec7310ad9ec47531.value
  instance_type               = "t2.micro"
  availability_zone           = "ap-northeast-3a"
  vpc_security_group_ids      = [aws_security_group.mk77-sg.id]
  subnet_id                   = aws_subnet.mk77-public-1a-sn.id
  associate_public_ip_address = "true"
  key_name                    = "${var.key_name}"
  tags = {
    Name = "mk77_ec2"
  }
}
Footer
© 2022 GitHub, Inc.
Footer navigation
Terms
Privacy
Security
Status
Docs
Contact GitHub
Pricing
API
Training
Blog
About
VPC-test/kiriyama.tf at kiriyama · team-buta/VPC-test
