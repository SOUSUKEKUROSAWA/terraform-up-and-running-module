module "simple_webapp" {
    source = "../../modules/services/kubernetes-app"

    name = "simple-webapp"
    image = "training/webapp"
    replicas = 2
    container_port = 5000

    environment_variables = {
        PROVIDER = "Terraform" # レスポンスが「Hello <PROVIDER>!」に変更される
    }
}