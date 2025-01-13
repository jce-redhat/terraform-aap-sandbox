resource "aws_db_subnet_group" "aap" {
  count = var.deploy_with_rds ? 1 : 0

  name       = "aap"
  subnet_ids = module.vpc.public_subnets

  tags = local.aws_tags
}

resource "aws_db_parameter_group" "aap" {
  count = var.deploy_with_rds ? 1 : 0

  name   = "aap"
  family = var.rds_db_family

  parameter {
    name  = "log_connections"
    value = "1"
  }
}

resource "aws_db_instance" "aap" {
  count = var.deploy_with_rds ? 1 : 0

  identifier           = "aap"
  instance_class       = var.rds_instance_type
  allocated_storage    = var.rds_storage_gb
  engine               = var.rds_engine
  engine_version       = var.rds_engine_version
  username             = var.rds_username
  password             = var.rds_password
  multi_az             = var.rds_multi_az
  db_subnet_group_name = aws_db_subnet_group.aap[0].name
  parameter_group_name = aws_db_parameter_group.aap[0].name
  publicly_accessible  = false
  skip_final_snapshot  = true

  vpc_security_group_ids = [
    aws_security_group.public_subnets.id,
    aws_security_group.default_egress.id
  ]

  lifecycle {
    precondition {
      condition     = var.rds_password != ""
      error_message = "The 'rds_password' variable or 'TF_VAR_rds_password' environment variable must be set to a non-empty string"
    }
    # TODO this doesn't work to make deploy_database_node and deploy_with_rds
    # mutually exclusive for some reason, need to find another way
    precondition {
      condition     = alltrue([var.deploy_database_node, var.deploy_with_rds])
      error_message = "The 'deploy_database_node' and 'deploy_with_rds' variables are mutually exclusive, only one can be set to 'true'"
    }
  }
}
