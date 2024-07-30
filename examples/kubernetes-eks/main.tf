module "eks_cluster" {
    source = "../../modules/services/eks-cluster"

    name = "example-eks-cluster"
    min_size = 1
    max_size = 2
    desired_size = 1

    # EKSがENIを使用する方法の制約により，t3.smallより小さいインスタンスタイプだと，
    # システムサービスしか起動できず，自分のPodをデプロイできない
    instance_types = ["t3.small"]
}

module "simple_webapp" {
    source = "../../modules/services/kubernetes-app"

    name = "simple-webapp"
    image = "training/webapp"
    replicas = 2
    container_port = 5000

    environment_variables = {
        PROVIDER = "Readers" # レスポンスが「Hello <PROVIDER>!」に変更される
    }

    # クラスタがデプロイされた後にアプリケーションをデプロイ
    depends_on = [module.eks_cluster]
}