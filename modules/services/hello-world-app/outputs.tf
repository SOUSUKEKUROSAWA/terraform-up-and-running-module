# モジュールで定義された出力変数はモジュール利用側で使えるようになるだけ
# -- Applyで出力するには，利用側の outputs.tf でここで定義した変数を指定してあげる必要があるので注意
output "alb_dns_name" {
    value = module.alb.alb_dns_name
    description = "The domain name of the load balancer"
}

output "asg_name" {
    value = module.asg.asg_name
    description = "The name of the Auto Scaling Group"
}

output "instance_security_group_id" {
    value = module.asg.instance_security_group_id
    description = "The ID of the Security Group attached to the load balancer"
}