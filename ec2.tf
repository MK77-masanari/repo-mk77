# ---------------------------
# EC2 Key pair
# ---------------------------
variable "key_name" {
  default = "mk77-keypair"
}

# 秘密鍵のアルゴリズム設定
resource "tls_private_key" "mk77-keypair-private-key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# クライアントPCにKey pair（秘密鍵と公開鍵）を作成
# - Windowsの場合はフォルダを"\\"で区切る（エスケープする必要がある）
# - [terraform apply] 実行後はクライアントPCの公開鍵は自動削除される
locals {
  public_key_file  = "C:\\work\\${var.key_name}.id_rsa.pub"
  private_key_file = "C:\\work\\${var.key_name}.id_rsa"
}

resource "local_file" "mk77-private-key-pem" {
  filename = "${local.private_key_file}"
  content  = "${tls_private_key.mk77_private_key.private_key_pem}"
}

# 上記で作成した公開鍵をAWSのKey pairにインポート
resource "aws_key_pair" "mk77_keypair" {
  key_name   = "${var.key_name}"
  public_key = "${tls_private_key.mk77_private_key.public_key_openssh}"
}

# ---------------------------
# EC2
# ---------------------------
# Amazon Linux 2 の最新版AMIを取得
data "aws_ssm_parameter" "amzn2_win_ami" {
  name = "/aws/service/ami-05d5d9a7872d5e73d"
}

# EC2作成
resource "aws_instance" "mk77_ec2"{
  ami                         = data.aws_ssm_parameter.amzn2_win_ami.value
  instance_type               = "t2.micro"
  availability_zone           = "ap-northeast-3a"
  vpc_security_group_ids      = [aws_security_group.mk77-sg.id]
  subnet_id                   = aws_subnet.mk77-public-1a-sn.id
  associate_public_ip_address = "true"
  key_name                    = "${var.key_name}"
  tags = {
    Name = "mk77-ec2"
  }
}
