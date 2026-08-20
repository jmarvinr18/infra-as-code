# ─────────────────────────────────────────────────────────────────────────────
# A single EC2 instance running Postgres + pgvector in Docker.
#
# This is the development fallback for the Aurora Serverless v2 + Data API
# store: same engine, same extension, reachable with an ordinary connection
# string. It exists so that a Data API quota, an unavailable engine version or
# any other cluster-side blocker cannot stall the Lambda work — point the
# functions at this host, keep building, move back when the cluster is ready.
#
# It is deliberately reachable from outside the VPC, because both of its
# callers are: a developer's SQL client (TablePlus, DBeaver, psql) and a Lambda
# that is not VPC-attached. That makes the security group the only thing
# standing in front of the database — set allowed_postgres_cidr_blocks
# narrowly, and treat the contents as disposable development data.
# ─────────────────────────────────────────────────────────────────────────────

data "aws_ami" "al2023" {
  count = var.ami_id == null ? 1 : 0

  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-${var.architecture}"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

locals {
  ami_id = var.ami_id != null ? var.ami_id : data.aws_ami.al2023[0].id

  security_group_ids = concat(
    var.create_security_group ? [aws_security_group.this[0].id] : [],
    var.vpc_security_group_ids,
  )

  user_data = templatefile("${path.module}/templates/bootstrap.sh.tftpl", {
    compose_version   = var.compose_version
    compose_dir       = var.compose_dir
    container_name    = var.container_name
    postgres_image    = var.postgres_image
    postgres_db       = var.postgres_db
    postgres_user     = var.postgres_user
    postgres_password = var.postgres_password
    postgres_port     = var.postgres_port
    max_connections   = var.max_connections
    shared_buffers    = var.shared_buffers
    shm_size          = var.shm_size
    extra_initdb      = var.extra_initdb_sql == null ? "" : <<-EOT
      cat > ${var.compose_dir}/initdb/001-schema.sql <<'EXTRASQL'
      ${var.extra_initdb_sql}
      EXTRASQL
    EOT
    extra_user_data   = var.extra_user_data
  })
}

# ─────────────────────────────────────────────────────────────────────────────
# Security group
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_security_group" "this" {
  count = var.create_security_group ? 1 : 0

  name        = "${var.name}-docker-host"
  description = "Postgres and administrative access for ${var.name}"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, { Name = "${var.name}-docker-host" })
}

resource "aws_vpc_security_group_ingress_rule" "postgres_from_cidr" {
  for_each = var.create_security_group ? { for i, cidr in var.allowed_postgres_cidr_blocks : tostring(i) => cidr } : {}

  security_group_id = aws_security_group.this[0].id
  description       = "Postgres from ${each.value}"
  cidr_ipv4         = each.value
  ip_protocol       = "tcp"
  from_port         = var.postgres_port
  to_port           = var.postgres_port
}

# Keyed by list position: a caller's security group is usually created in the
# same apply, so its id is unknown at plan time and cannot be a for_each key.
resource "aws_vpc_security_group_ingress_rule" "postgres_from_security_group" {
  for_each = var.create_security_group ? { for i, id in var.allowed_postgres_security_group_ids : tostring(i) => id } : {}

  security_group_id            = aws_security_group.this[0].id
  description                  = "Postgres from source security group ${each.key}"
  referenced_security_group_id = each.value
  ip_protocol                  = "tcp"
  from_port                    = var.postgres_port
  to_port                      = var.postgres_port
}

# Only created when a key pair is supplied. The default path is Session
# Manager, which needs no open port and no key material on anyone's laptop.
resource "aws_vpc_security_group_ingress_rule" "ssh" {
  for_each = var.create_security_group && var.key_name != null ? { for i, cidr in var.allowed_ssh_cidr_blocks : tostring(i) => cidr } : {}

  security_group_id = aws_security_group.this[0].id
  description       = "SSH from ${each.value}"
  cidr_ipv4         = each.value
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

# Outbound is unrestricted: the instance pulls its container image, packages
# and SSM agent updates from the internet.
resource "aws_vpc_security_group_egress_rule" "all" {
  count = var.create_security_group ? 1 : 0

  security_group_id = aws_security_group.this[0].id
  description       = "Allow all outbound"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# ─────────────────────────────────────────────────────────────────────────────
# Instance role — Session Manager only, so there is no SSH key to circulate
# and no bastion to run.
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_iam_role" "this" {
  count = var.create_instance_profile ? 1 : 0

  name = "${var.name}-docker-host"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = var.create_instance_profile ? toset(concat(
    ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"],
    var.additional_policy_arns,
  )) : toset([])

  role       = aws_iam_role.this[0].name
  policy_arn = each.value
}

resource "aws_iam_instance_profile" "this" {
  count = var.create_instance_profile ? 1 : 0

  name = "${var.name}-docker-host"
  role = aws_iam_role.this[0].name

  tags = var.tags
}

# ─────────────────────────────────────────────────────────────────────────────
# Instance
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_instance" "this" {
  ami           = local.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  key_name      = var.key_name

  vpc_security_group_ids = local.security_group_ids
  iam_instance_profile   = var.create_instance_profile ? aws_iam_instance_profile.this[0].name : var.iam_instance_profile

  # False when an Elastic IP is attached instead — a stop/start would otherwise
  # hand out a new address and break every saved connection.
  associate_public_ip_address = var.create_eip ? false : var.associate_public_ip_address

  user_data                   = local.user_data
  user_data_replace_on_change = var.user_data_replace_on_change

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    encrypted             = true
    delete_on_termination = true
    tags                  = merge(var.tags, { Name = "${var.name}-root" })
  }

  # IMDSv2 only. The metadata service is where an SSRF bug goes looking for
  # instance credentials, and token-required mode closes that path.
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  monitoring = var.detailed_monitoring

  tags = merge(var.tags, { Name = var.name })

  lifecycle {
    precondition {
      condition     = !var.create_security_group || length(var.allowed_postgres_cidr_blocks) > 0 || length(var.allowed_postgres_security_group_ids) > 0
      error_message = "Nothing can reach Postgres on this host. Set allowed_postgres_cidr_blocks to the addresses that need it, e.g. [\"203.0.113.4/32\"]."
    }
  }
}

resource "aws_eip" "this" {
  count = var.create_eip ? 1 : 0

  instance = aws_instance.this.id
  domain   = "vpc"

  tags = merge(var.tags, { Name = var.name })
}
