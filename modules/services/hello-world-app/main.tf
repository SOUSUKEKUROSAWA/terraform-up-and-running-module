module "asg" {
    source = "../../modules/cluster/asg-rolling-deploy"

    cluster_name = "hello-world-${var.environment}"
    ami = var.ami
    instance_type = var.instance_type

    user_data = templatefile("${path.module}/user-data.sh", {
        server_port = var.server_port
        db_address = data.terraform_remote_state.db.outputs.address
        db_port = data.terraform_remote_state.db.outputs.port
        server_text = var.server_text
    })

    min_size = var.min_size
    max_size = var.max_size
    enable_autoscaling = var.enable_autoscaling

    subnet_ids = data.aws_subnets.default.ids
    target_group_arns = [aws_lb_target_group.asg.arn]
    health_check_type = "ELB"

    custom_tags = var.custom_tags
}

module "alb" {
    source = "../../modules/networking/alb"

    alb_name = "hello-world-${var.environment}"
    subnet_ids = data.aws_subnets.default.ids
}

# ロードバランサからリクエストを受け取るサーバ群
# サーバに対するヘルスチェックも行い，チェックをパスしたノードにリクエストを送る
resource "aws_lb_target_group" "asg" {
    name = "hello-world-${var.environment}"
    port = var.server_port
    protocol = "HTTP"
    vpc_id = data.aws_vpc.default.id

    health_check {
        path = "/"
        protocol = "HTTP"
        matcher = "200" # レスポンスが200 OKであるかをチェック
        interval = 15
        timeout = 3
        healthy_threshold = 2
        unhealthy_threshold = 2
    }
}

# リスナに対するアクセスを受け取り，特定のパスやホスト名に一致したリクエストを，指定したターゲットグループに送信する
resource "aws_lb_listener_rule" "asg" {
    listener_arn = module.alb.alb_http_listhener_arn
    priority = 100

    condition {
        path_pattern {
            values = ["*"]
        }
    }

    action {
        type = "forward"
        target_group_arn = aws_lb_target_group.asg.arn
    }
}