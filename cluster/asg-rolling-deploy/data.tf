# AWSが提供するデータソースからデフォルトVPCの情報を使える状態にする
data "aws_vpc" "default" {
    default = true
}