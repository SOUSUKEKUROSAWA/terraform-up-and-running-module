resource "aws_db_instance" "example" {
    identifier_prefix = "terraform-up-and-running"
    allocated_storage = 10
    instance_class = "db.t3.micro" # 2024/06よりdb.t2はサポートされなくなったためt3を選択
    skip_final_snapshot = true

    # バックアップを有効化
    backup_retention_period = var.backup_retenstion_period

    # 設定されているときはこのデータベースはレプリカ
    replicate_source_db = var.replicate_source_db

    # リードレプリカとして定義される場合は以下のパラメータは設定できない
    engine = var.replicate_source_db == null ? "mysql" : null
    db_name = var.replicate_source_db == null ? var.db_name : null
    username = var.replicate_source_db == null ? var.db_username : null
    password = var.replicate_source_db == null ? var.db_password : null
}