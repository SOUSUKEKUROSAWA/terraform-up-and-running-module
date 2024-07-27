locals {
    pod_labels = {
        app = var.name
    }

    status = kubernetes_service.app.status
}