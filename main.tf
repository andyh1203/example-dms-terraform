provider "aws" {
  region = "us-west-2"
}

module "vpc" {
  source   = "./modules/vpc"
  local_ip = var.local_ip
}

module "compute" {
  source                 = "./modules/compute"
  subnet_id              = module.vpc.subnet_ids["public_a"]
  vpc_security_group_ids = module.vpc.vpc_security_group_ids
}

module "rds" {
  source                     = "./modules/rds"
  db_name                    = var.db_name
  db_allocated_storage       = var.db_allocated_storage
  db_storage_type            = var.db_storage_type
  db_engine                  = var.db_engine
  db_engine_version          = var.db_engine_version
  db_instance_class          = var.db_instance_class
  db_username                = var.db_username
  db_password                = var.db_password
  db_skip_final_snapshot     = var.db_skip_final_snapshot
  db_subnet_group_name       = module.vpc.db_subnet_group_name
  vpc_rds_security_group_ids = module.vpc.vpc_rds_security_group_ids
}

module "s3" {
  source = "./modules/s3"
}

module "dms" {
  source = "./modules/dms"
}
