resource "aws_subnet" "private-ap-southeast-1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.cidr-priv-1a
  availability_zone = "ap-southeast-1a"

  tags = {
    "Name"                                      = "private-ap-southeast-1a"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "${var.elb_subnet_state}"
  }
}

resource "aws_subnet" "private-ap-southeast-1b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.cidr-priv-1b
  availability_zone = "ap-southeast-1b"

  tags = {
    "Name"                                      = "private-ap-southeast-1b"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "${var.elb_subnet_state}"
  }
}

resource "aws_subnet" "private-ap-southeast-1c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.cidr-priv-1c
  availability_zone = "ap-southeast-1c"

  tags = {
    "Name"                                      = "private-ap-southeast-1c"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "${var.elb_subnet_state}"
  }
}



resource "aws_subnet" "public-ap-southeast-1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.cidr-pub-1a
  availability_zone       = "ap-southeast-1a"
  map_public_ip_on_launch = true

  tags = {
    "Name"                                      = "public-ap-southeast-1a"
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "${var.elb_subnet_state}"
  }
}

resource "aws_subnet" "public-ap-southeast-1b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.cidr-pub-1b
  availability_zone       = "ap-southeast-1b"
  map_public_ip_on_launch = true

  tags = {
    "Name"                                      = "public-ap-southeast-1b"
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "${var.elb_subnet_state}"
  }
}

resource "aws_subnet" "public-ap-southeast-1c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.cidr-pub-1c
  availability_zone       = "ap-southeast-1c"
  map_public_ip_on_launch = true

  tags = {
    "Name"                                      = "public-ap-southeast-1c"
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "${var.elb_subnet_state}"
  }
}