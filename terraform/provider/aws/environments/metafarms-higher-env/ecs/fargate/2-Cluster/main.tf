##############################################################
##                     Cluster Creation                     ##
##############################################################

module "cluster" {
  source           = "../../../../../modules/ecs/cluster"
  app_cluster_name = var.app_cluster_name
  tags = var.tags
  
}



##############################################################
##                    Load Balancer Creation                ##
##############################################################

module "sg" {
  source              = "../../../../../modules/sg"
  security_group_name = var.security_group_name
  ingress_rules       = var.ingress_rules
  vpc_id              = data.aws_vpc.this.id
  tags                = var.tags
}


module "target_group" {
  source      = "../../../../../modules/elb/lb_target_group"
  name        = var.target_group_name
  port        = var.target_group_port
  protocol    = var.target_group_protocol
  target_type = var.target_type

  vpc_id                     = data.aws_vpc.this.id

  health_check = {
    path                = var.health_check.path
    port                = var.instance_target_group_port
    healthy_threshold   = var.health_check.healthy_threshold
    unhealthy_threshold = var.health_check.unhealthy_threshold

  }
  tags = var.tags

}

module "load_balancer" {
  source                     = "../../../../../modules/elb/lb"
  name                       = var.load_balancer_name
  security_groups            = [module.sg.id]
  subnets                    = [for i in data.aws_subnets.this.ids : i]
  enable_deletion_protection = false


  access_logs = {
    "bucket"  = "xctuality-bucket"
    "prefix"  = "production"
    "enabled" = false
  }

  tags = var.tags

}

module "listener_and_routing" {
  for_each          = { for i, listener in var.elb_listeners : i => listener }
  source            = "../../../../../modules/elb/lb_listener"
  load_balancer_arn = module.load_balancer.arn

  protocol = each.value.protocol
  port     = each.value.port

  ssl_policy      = var.ssl_policy
  certificate_arn = var.certificate_arn

  type             = each.value.default_action.type
  target_group_arn = module.target_group.arn


  redirect_port        = each.value.default_action.redirect.port
  redirect_protocol    = each.value.default_action.redirect.protocol
  redirect_status_code = each.value.default_action.redirect.redirect_status_code

  # depends_on = [module.launch_template]
}
