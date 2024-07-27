# ここで設定された状態を満たすように調整ループが動作する
resource "kubernetes_deployment" "app" {
    metadata {
        name = var.name
    }

    spec {
        replicas = var.replicas

        # Podテンプレート．Pod = 一緒にデプロイされるコンテナのグループ
        template {
            metadata {
                labels = local.pod_labels
            }

            spec {
                container {
                    name = var.name
                    image = var.image

                    port {
                        container_port = var.container_port
                    }

                    dynamic "env" {
                        for_each = var.environment_variables

                        content {
                            name = env.key
                            value = env.value
                        }
                    }
                }
            }
        }

        # Kubernetes Deploymentが何をターゲットにするか
        # -- Kubernetes Deploymentは別に定義されたPodに対するDeploymentも定義できる柔軟さを持っているがゆえに，
        # -- 同じDeployment内のPodでも明示的にターゲットに指定する必要がある
        selector {
            match_labels = local.pod_labels
        }
    }
}

resource "kubernetes_service" "app" {
    metadata {
        name = var.name
    }

    spec {
        type = "LoadBalancer"

        port {
            port = 80
            target_port = var.container_port
            protocol = "TCP"
        }

        selector = local.pod_labels
    }
}