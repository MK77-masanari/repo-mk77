#変数
variable "key_name" {
  type        = "string"
  description = "keypair name"
  default    = "mk77-key" # キー名を固定したかったらdefault指定。指定なしならインタラクティブにキー入力して決定。
}

# キーファイル
## 生成場所のPATH指定をしたければ、ここを変更するとよい。
locals {
  public_key_file  = "C:\\C:\work\\${var.key_name}.id_rsa.pub"
  private_key_file = "C:\\C:\work\\${var.key_name}.id_rsa"
}

# キーペアを作る
resource "tls_private_key" "mk77-keypair" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# 秘密鍵ファイルを作る
resource "local_file" "mk77-private_key_pem" {
  filename = "${local.private_key_file}"
  content  = "${tls_private_key.mk77-keypair.private_key_pem}"

  # local_fileでファイルを作ると実行権限が付与されてしまうので、local-execでchmodしておく。
  provisioner "local-exec" {
    command = "chmod 600 ${local.private_key_file}"
  }
}

resource "local_file" "public_key_openssh" {
  filename = "${local.public_key_file}"
  content  = "${tls_private_key.mk77-keypair.public_key_openssh}"

  # local_fileでファイルを作ると実行権限が付与されてしまうので、local-execでchmodしておく。
  provisioner "local-exec" {
    command = "chmod 600 ${local.public_key_file}"
  }
}

# キー名
output "key_name" {
  value = "${var.key_name}"
}

# 秘密鍵ファイルPATH（このファイルを利用してサーバへアクセスする。）
output "private_key_file" {
  value = "${local.private_key_file}"
}

# 秘密鍵内容
output "private_key_pem" {
  value = "${tls_private_key.mk77-keypair.private_key_pem}"
}

# 公開鍵ファイルPATH
output "public_key_file" {
  value = "${local.public_key_file}"
}

# 公開鍵内容（サーバの~/.ssh/authorized_keysに登録して利用する。）
output "public_key_openssh" {
  value = "${tls_private_key.mk77-keypair.public_key_openssh}"
}

# ---------------------------
# EC2
# ---------------------------
# Amazon Linux 2 の最新版AMIを取得
data "aws_ssm_parameter" "amzn2_win2019_ami" {
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
