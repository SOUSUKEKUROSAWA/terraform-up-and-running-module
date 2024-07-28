# Auto Scaling Group（ASG） 内のインスタンスの起動設定（起動テンプレートを使うのが一般的 https://docs.aws.amazon.com/ja_jp/autoscaling/ec2/userguide/launch-templates.html）
resource "aws_launch_configuration" "example" {
    image_id = var.ami
    instance_type = var.instance_type
    security_groups = [aws_security_group.instance.id]

    # 最初のインスタンス起動時にのみ実行されるスクリプト
    user_data = var.user_data

    # ASGからの参照を失わないように変更を適用する
    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "example" {
    name = var.cluster_name
    launch_configuration = aws_launch_configuration.example.name
    vpc_zone_identifier = var.subnet_ids

    # ロードバランサとの組み合わせを設定
    target_group_arns = var.target_group_arns
    health_check_type = var.health_check_type

    min_size = var.min_size
    max_size = var.max_size

    # ASGが更新された時必ずインスタンスのリフレッシュを行う（ネイティブなゼロダウンタイムデプロイ）
    instance_refresh {
        strategy = "Rolling"
        preferences {
            min_healthy_percentage = 50
        }
    }

    tag {
        key = "Name"
        value = var.cluster_name
        propagate_at_launch = true
    }

    # dynamic "<ループしたいブロック名>"
    dynamic "tag" {
        for_each = var.custom_tags

        content {
            key = tag.key
            value = tag.value
            propagate_at_launch = true
        }
    }
}

# 条件付きリソース（このリソースを作成するかをモジュールの利用者側が決められる）
resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
    count = var.enable_autoscaling ? 1 : 0

    scheduled_action_name = "scale-out-during-business-hours"
    min_size = 2
    max_size = 10
    desired_capacity = 10
    recurrence = "0 9 * * *"
    autoscaling_group_name = aws_autoscaling_group.example.name
}

resource "aws_autoscaling_schedule" "scale_in_at_night" {
    count = var.enable_autoscaling ? 1 : 0

    scheduled_action_name = "scale-in-at-night"
    min_size = 2
    max_size = 10
    desired_capacity = 2
    recurrence = "0 17 * * *"
    autoscaling_group_name = aws_autoscaling_group.example.name
}

resource "aws_security_group" "instance" {
    name = "${var.cluster_name}-instance"
}

# モジュールの柔軟性を高めるためにASGとは別リソースで定義
# -- SGのリソース内にインラインブロックとして定義するとモジュール利用側で aws_security_group_rule を追加できなくなってしまう
# -- ex. Stage環境でのみインバウンドを許可するポートを増やしたい場合など
resource "aws_security_group_rule" "allow_server_http_inbound" {
    type = "ingress"
    security_group_id = aws_security_group.instance.id

    # Webサーバへのアクセスを許可
    from_port = var.server_port
    to_port = var.server_port
    protocol = local.tcp_protocol
    cidr_blocks = local.all_ips # アクセス可能なIPアドレス範囲
}