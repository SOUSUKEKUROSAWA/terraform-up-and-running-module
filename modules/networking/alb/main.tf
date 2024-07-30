resource "aws_lb" "example" {
    name = var.alb_name
    load_balancer_type = "application"

    subnets = var.subnet_ids

    security_groups = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.example.arn
    port = local.http_port
    protocol = "HTTP"

    # リスナールールに一致しないリクエストに対するレスポンス
    default_action {
        type = "fixed-response"

        fixed_response {
            content_type = "text/plain"
            message_body = "404: page not found"
            status_code = 404
        }
    }
}

resource "aws_security_group" "alb" {
    name = "${var.alb_name}-alb"
}

# モジュールの柔軟性を高めるためにASGとは別リソースで定義
# -- SGのリソース内にインラインブロックとして定義するとモジュール利用側で aws_security_group_rule を追加できなくなってしまう
# -- ex. Stage環境でのみインバウンドを許可するポートを増やしたい場合など
resource "aws_security_group_rule" "allow_http_inbound" {
    type = "ingress"
    security_group_id = aws_security_group.alb.id

    from_port = local.http_port
    to_port = local.http_port
    protocol = local.tcp_protocol # TCPはトランスポート層のプロトコルで，HTTPはこの上で動作する
    cidr_blocks = local.all_ips
}

resource "aws_security_group_rule" "allow_http_outbound" {
    type = "egress"
    security_group_id = aws_security_group.alb.id

    # EC2クラスタに対するヘルスチェックのため，全開放
    from_port = local.any_port
    to_port = local.any_port
    protocol = local.any_protocol
    cidr_blocks = local.all_ips
}