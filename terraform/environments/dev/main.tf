# ─── NETWORKING ─────────────────────────────────────────
module "networking" {
  source = "../../modules/networking"

  project              = var.project
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  app_port             = var.app_port
}

# ─── ECR ────────────────────────────────────────────────
module "ecr" {
  source = "../../modules/ecr"

  project     = var.project
  environment = var.environment
}

# ─── IAM ────────────────────────────────────────────────
module "iam" {
  source = "../../modules/iam"

  project     = var.project
  environment = var.environment
}

# ─── ALB ────────────────────────────────────────────────
module "alb" {
  source = "../../modules/alb"

  project           = var.project
  environment       = var.environment
  vpc_id            = module.networking.vpc_id
  public_subnet_ids = module.networking.public_subnet_ids
  alb_sg_id         = module.networking.alb_sg_id
  app_port          = var.app_port
}

# ─── ECS ────────────────────────────────────────────────
module "ecs" {
  source = "../../modules/ecs"

  project            = var.project
  environment        = var.environment
  aws_region         = var.aws_region
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  ecs_tasks_sg_id    = module.networking.ecs_tasks_sg_id
  execution_role_arn = module.iam.ecs_task_execution_role_arn
  task_role_arn      = module.iam.ecs_task_role_arn
  ecr_repository_url = module.ecr.repository_url
  image_tag          = var.image_tag
  app_port           = var.app_port
  target_group_arn   = module.alb.target_group_arn
}

# ─── MONITORING ─────────────────────────────────────────
module "monitoring" {
  source = "../../modules/monitoring"

  project        = var.project
  environment    = var.environment
  aws_region     = var.aws_region
  cluster_name   = module.ecs.cluster_name
  service_name   = module.ecs.service_name
  log_group_name = module.ecs.log_group_name
}