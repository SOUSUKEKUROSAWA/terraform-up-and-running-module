resource "aws_eks_cluster" "cluster" {
    name = var.name
    role_arn = aws_iam_role.cluster.arn
    version = "1.27"

    vpc_config {
        subnet_ids = data.aws_subnets.default.ids
    }

    # IAMロールの権限が，EKSクラスタの前に作られ，後に削除されるようにする
    depends_on = [
        aws_iam_role_policy_attachment.AmazonEKSClusterPolicy
    ]
}

resource "aws_eks_node_group" "nodes" {
    cluster_name = aws_eks_cluster.cluster.name
    node_group_name = var.name
    node_role_arn = aws_iam_role.node_group.arn
    subnet_ids = data.aws_subnets.default.ids
    instance_types = var.instance_types

    scaling_config {
        min_size = var.min_size
        max_size = var.max_size
        desired_size = var.desired_size
    }

    # IAMロールの権限が，EKSノードグループの前に作られ，後に削除されるようにする
    depends_on = [
        aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
        aws_iam_role_policy_attachment.AmazonEC2ContanerRegistryReadOnly,
        aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy
    ]
}

# コントロールプレーン用のIAMロール
resource "aws_iam_role" "cluster" {
    name = "${var.name}-cluster-role"
    assume_role_policy = data.aws_iam_policy_document.cluster_assume_role.json
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    role = aws_iam_role.cluster.name
}

# ノードグループ用のIAMロール
resource "aws_iam_role" "node_group" {
    name = "${var.name}-node-group"
    assume_role_policy = data.aws_iam_policy_document.node_assume_role.json
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    role = aws_iam_role.node_group.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContanerRegistryReadOnly" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    role = aws_iam_role.node_group.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    role = aws_iam_role.node_group.name
}