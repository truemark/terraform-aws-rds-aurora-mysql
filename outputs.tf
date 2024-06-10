output "instances" {
  value = local.instances
}

###############################################################################
# The following parameters are copied from
# https://github.com/terraform-aws-modules/terraform-aws-rds-aurora/blob/v9.2.1/outputs.tf
###############################################################################

# aws_db_subnet_group
output "db_subnet_group_name" {
  description = "The db subnet group name"
  value       = module.db.db_subnet_group_name
}

# aws_rds_cluster
output "cluster_arn" {
  description = "Amazon Resource Name (ARN) of cluster"
  value       = module.db.cluster_arn
}

output "cluster_id" {
  description = "The RDS Cluster Identifier"
  value       = module.db.cluster_id
}

output "cluster_resource_id" {
  description = "The RDS Cluster Resource ID"
  value       = module.db.cluster_resource_id
}

output "cluster_members" {
  description = "List of RDS Instances that are a part of this cluster"
  value       = module.db.cluster_members
}

output "cluster_endpoint" {
  description = "Writer endpoint for the cluster"
  value       = module.db.cluster_endpoint
}

output "cluster_reader_endpoint" {
  description = "A read-only endpoint for the cluster, automatically load-balanced across replicas"
  value       = module.db.cluster_reader_endpoint
}

output "cluster_engine_version_actual" {
  description = "The running version of the cluster database"
  value       = module.db.cluster_engine_version_actual
}

# database_name is not set on `aws_rds_cluster` resource if it was not specified, so can't be used in output
output "cluster_database_name" {
  description = "Name for an automatically created database on cluster creation"
  value       = module.db.cluster_database_name
}

output "cluster_port" {
  description = "The database port"
  value       = module.db.cluster_port
}

output "cluster_master_password" {
  description = "The database master password"
  value       = module.db.cluster_master_password
  sensitive   = true
}

output "cluster_master_username" {
  description = "The database master username"
  value       = module.db.cluster_master_username
  sensitive   = true
}

output "cluster_master_user_secret" {
  description = "The generated database master user secret when `manage_master_user_password` is set to `true`"
  value       = module.db.cluster_master_user_secret
}

output "cluster_hosted_zone_id" {
  description = "The Route53 Hosted Zone ID of the endpoint"
  value       = module.db.cluster_hosted_zone_id
}

# aws_rds_cluster_instances
output "cluster_instances" {
  description = "A map of cluster instances and their attributes"
  value       = module.db.cluster_instances
}

# aws_rds_cluster_endpoint
output "additional_cluster_endpoints" {
  description = "A map of additional cluster endpoints and their attributes"
  value       = module.db.additional_cluster_endpoints
}

# aws_rds_cluster_role_association
output "cluster_role_associations" {
  description = "A map of IAM roles associated with the cluster and their attributes"
  value       = module.db.cluster_role_associations
}

# Enhanced monitoring role
output "enhanced_monitoring_iam_role_name" {
  description = "The name of the enhanced monitoring role"
  value       = module.db.enhanced_monitoring_iam_role_name
}

output "enhanced_monitoring_iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the enhanced monitoring role"
  value       = module.db.enhanced_monitoring_iam_role_arn
}

output "enhanced_monitoring_iam_role_unique_id" {
  description = "Stable and unique string identifying the enhanced monitoring role"
  value       = module.db.enhanced_monitoring_iam_role_unique_id
}

# aws_security_group
output "security_group_id" {
  description = "The security group ID of the cluster"
  value       = module.db.security_group_id
}

# Cluster Parameter Group
output "db_cluster_parameter_group_arn" {
  description = "The ARN of the DB cluster parameter group created"
  value       = module.db.db_cluster_parameter_group_arn
}

output "db_cluster_parameter_group_id" {
  description = "The ID of the DB cluster parameter group created"
  value       = module.db.db_cluster_parameter_group_id
}

# DB Parameter Group
output "db_parameter_group_arn" {
  description = "The ARN of the DB parameter group created"
  value       = module.db.db_parameter_group_arn
}

output "db_parameter_group_id" {
  description = "The ID of the DB parameter group created"
  value       = module.db.db_parameter_group_id
}

# CloudWatch Log Group
output "db_cluster_cloudwatch_log_groups" {
  description = "Map of CloudWatch log groups created and their attributes"
  value       = module.db.db_cluster_cloudwatch_log_groups
}

# Cluster Activity Stream
output "db_cluster_activity_stream_kinesis_stream_name" {
  description = "The name of the Amazon Kinesis data stream to be used for the database activity stream"
  value       = module.db.db_cluster_activity_stream_kinesis_stream_name
}

# Managed Secret Rotation
output "db_cluster_secretsmanager_secret_rotation_enabled" {
  description = "Specifies whether automatic rotation is enabled for the secret"
  value       = module.db.db_cluster_secretsmanager_secret_rotation_enabled
}
