#### EC2 INSTANCE VALUES ####

aws_key_name           = "dingdong-production-key"
key_name               = "provisioner-key.pub"
key_path               = "/mnt/d/Users/RouVin/Documents/xctuality/devops/infra-as-code/terraform/provider/aws/projects/dingdong/staging/ecs-bundle/.ssh"
key_pair               = ""
vpc_security_group_ids = ["sg-0afcc88276a07d362"]
amis                   = "ami-047126e50991d067b"
subnet_id              = "subnet-0e1f9878"
private_key            = "provisioner-key"
user                   = "ubuntu"
iam_instance_profile   = "ECSInstanceRole"
instance_type          = "t3.medium"


ami_from_instance_name = "DINGDONG-PROD-AMI"

launch_template_name_prefix = "dingdong-"

tags = {
  "Name"        = "ECS-RESOURCE-DINGDONG"
  "Environment" = "PRODUCTION"
  "Release"     = "latest"
  "Created-by"  = "terraform-jmr"
}


#### LOAD BALANCER VALUES ####

target_group_name     = "DINGDONG-TG"
target_group_port     = 80
target_group_protocol = "HTTP"
target_type = "instance"

instance_target_group_port = 3000

load_balancer_name = "DINGDONG-ALB"

health_check = {
  path                = "/sign-in"
  port                = 3000
  healthy_threshold   = 3
  unhealthy_threshold = 10
}

certificate_arn = "arn:aws:acm:ap-southeast-1:664812007902:certificate/c4ee69a9-e608-4b8e-8d91-012b0894b839"
ssl_policy      = "ELBSecurityPolicy-2016-08"

elb_listeners = [
  {
    port     = "80"
    protocol = "HTTP"

    default_action = {
      type = "redirect"

      redirect = {
        port                 = "443"
        protocol             = "HTTPS"
        redirect_status_code = "HTTP_301"
      }
    }
  },
  {
    port     = "443"
    protocol = "HTTPS"

    default_action = {
      type = "forward"
      redirect = {
        port                 = null
        protocol             = null
        redirect_status_code = null
      }
    }
  },
]

asg_availability_zones = ["ap-southeast-1a"]

min_size         = 0
max_size         = 1
desired_capacity = 0



# Security Group Variables
security_group_name = "xcorp-production-sg"
vpc_id              = "vpc-4dba6b29"
ingress_rules = [
  {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = ""
  },
  {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = ""
  },
  {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = ""
  },
  {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = ""
  },
]

asg_name = "dingdong-asg"


profile = "xctuality"
region  = "ap-southeast-1"


cloudflare_api_token = "O6FQZbFpT1lQ0TTkQDXYXa4YCYelT0L2iZt9fPsM"
zone_id              = "9e15a2356dd49779a8d18408e6f4bd1d"
name                 = "dd-test"
type                 = "CNAME"
ttl                  = 1
proxied              = false