# AWSが提供するデータソースからデフォルトVPCの情報を使える状態にする
data "aws_vpc" "default" {
    default = true
}

data "aws_ec2_instance_type" "instance" {
    instance_type = var.instance_type
}