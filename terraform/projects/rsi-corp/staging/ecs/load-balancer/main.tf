data "aws_instance" "this" {
  filter {
    name   = "tag:Name"
    values = ["ECS-AGENT-RSI"]
  }  
  filter {
    name   = "tag:Created-by"
    values = ["terraform-jmr"]
  }    
}

module "target-group" {
    source = "../../../../../modules/aws/elb/lb_target_group"
    name = "ECSTARGETGROUP"
    vpc_id = data.aws_vpc.selected.id
    instance_target_group_port = 80
    aws_instance_target_id = data.aws_instance.this.id
}


module "listener-and-routing" {
    source = "../../../../../modules/aws/elb/lb_listener"
    target_group_arn = module.target-group.arn
    load_balancer_arn = module.load-balancer.arn
    port = "80"
    
}
module "load-balancer" {
  source          = "../../../../../modules/aws/elb/lb"
  name            = "ECSALB"
  security_groups = [data.aws_security_group.this.id]
  subnets         = [for i in data.aws_subnets.selected.ids : i]
  enable_deletion_protection = false


  access_logs = {
    "bucket"  = "rsi-lower-bucket"
    "prefix"  = "staging"
    "enabled" = false
  }
}