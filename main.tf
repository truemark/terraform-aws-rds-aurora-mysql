locals {
  instances = {
    for n in range(1, var.replica_count + 2) :
    n => {}
  }
  tags = merge(var.tags,
    {
      "automation:component-id"     = "rds-aurora-mysql",
      "automation:component-url"    = "https://registry.terraform.io/modules/truemark/rds-aurora-mysql/aws/latest",
      "automation:component-vendor" = "TrueMark",
      "backup:policy"               = "default-week",
  })
}

resource "aws_db_parameter_group" "db" {
  count       = var.create && var.db_parameter_group_name == null ? 1 : 0
  name        = var.name
  family      = var.family
  description = "Parameter group for ${var.name}"
  dynamic "parameter" {
    for_each = var.db_parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }
  tags = merge(var.tags, var.db_parameter_group_tags)
}

resource "aws_rds_cluster_parameter_group" "db" {
  count       = var.create && var.rds_cluster_parameter_group_name == null ? 1 : 0
  name        = var.name
  family      = var.family
  description = "Cluster parameter group for ${var.name}"
  dynamic "parameter" {
    for_each = var.rds_cluster_parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }
  tags = merge(var.tags, var.rds_cluster_parameter_group_tags)
}

resource "aws_security_group" "mysql_sg" {
  name        = "mysql_security_group"
  description = "Allow inbound traffic"
  vpc_id      = var.vpc_id
  #vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = var.ingress_cidrs #Change This
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.egress_cidrs #Change This
  }

  tags = {
    Name = "mysql_sg"
  }
}

module "db" {
  # https://registry.terraform.io/modules/terraform-aws-modules/rds-aurora/aws/latest
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "9.3.1"

  apply_immediately                     = var.apply_immediately
  auto_minor_version_upgrade            = var.auto_minor_version_upgrade
  backup_retention_period               = var.backup_retention_period
  ca_cert_identifier                    = var.ca_cert_identifier
  cluster_tags                          = var.cluster_tags
  copy_tags_to_snapshot                 = var.copy_tags_to_snapshot
  create                                = true
  create_db_subnet_group                = var.create_db_subnet_group
  create_security_group                 = var.create_security_group
  database_name                         = var.database_name
  db_cluster_parameter_group_name       = var.rds_cluster_parameter_group_name == null ? element(aws_rds_cluster_parameter_group.db.*.name, 1) : var.rds_cluster_parameter_group_name
  db_parameter_group_name               = var.db_parameter_group_name == null ? element(aws_db_parameter_group.db.*.name, 1) : var.db_parameter_group_name
  deletion_protection                   = var.deletion_protection
  enabled_cloudwatch_logs_exports       = ["audit", "error", "general", "slowquery"]
  engine                                = "aurora-mysql"
  engine_version                        = var.engine_version
  engine_mode                           = "provisioned"
  instance_class                        = var.instance_class
  instances                             = local.instances
  kms_key_id                            = var.kms_key_id
  manage_master_user_password           = var.manage_master_user_password
  master_password                       = var.master_password
  master_username                       = var.master_username
  monitoring_interval                   = 60
  name                                  = var.name
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_retention_period
  preferred_backup_window               = var.preferred_backup_window
  preferred_maintenance_window          = var.preferred_maintenance_window
  security_group_tags                   = var.security_group_tags
  skip_final_snapshot                   = var.skip_final_snapshot
  snapshot_identifier                   = var.snapshot_identifier
  storage_encrypted                     = true
  subnets                               = var.subnets
  tags                                  = var.tags
  vpc_id                                = var.vpc_id
  vpc_security_group_ids                = [aws_security_group.mysql_sg.id]
}

resource "aws_ram_resource_share" "db" {
  count                     = var.create && var.share ? 1 : 0
  name                      = "${var.name}-rds"
  allow_external_principals = false
  tags                      = merge(var.tags, var.share_tags)
}

resource "aws_secretsmanager_secret" "db" {
  count       = var.create && var.store_master_password_as_secret ? 1 : 0
  name_prefix = var.master_password_secret_name_prefix == null ? "database/${var.name}/master-" : var.master_password_secret_name_prefix
  description = "Master password for ${var.name}"
  tags        = merge(var.tags, var.password_secret_tags)
}

resource "aws_secretsmanager_secret_version" "db" {
  count     = var.create && var.store_master_password_as_secret ? 1 : 0
  secret_id = aws_secretsmanager_secret.db[count.index].id
  secret_string = jsonencode({
    host     = module.db.cluster_endpoint  #try(aws_rds_cluster.this[0].endpoint, "")
    port     = module.db.cluster_port
    dbname   = module.db.cluster_database_name
    username = module.db.cluster_master_username
    password = module.db.cluster_master_password
  })
}

module "proxy" {
  count                 = var.create && var.create_proxy ? 1 : 0
  source                = "truemark/rds-proxy/aws"
  version               = "0.0.1"
  create_proxy          = var.create_proxy
  name                  = var.name
  secret_arns           = concat([aws_secretsmanager_secret.db[count.index].arn], var.proxy_secret_arns)
  subnets               = var.subnets
  vpc_id                = var.vpc_id
  debug_logging         = var.proxy_debug_logging
  idle_client_timeout   = var.proxy_idle_client_timeout
  require_tls           = var.proxy_require_tls
  engine_family         = "MYSQL"
  iam_auth              = var.proxy_iam_auth
  db_cluster_identifier = module.db.cluster_id
  rds_security_group_id = module.db.security_group_id
}
