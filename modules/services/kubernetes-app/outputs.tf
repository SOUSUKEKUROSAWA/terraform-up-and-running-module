# 必要なロードバランサのホスト名
output "service_endpoint" {
    value = try(
        "http://${local.status[0]["load_balancer"][0]["ingress"][0]["hostname"]}",
        "(error parsing hostname from status)"
    )
    description = "The Kubernetes Service endpoint"
}