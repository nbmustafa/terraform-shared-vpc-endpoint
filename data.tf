data aws_region current {
}

data aws_caller_identity current {
}

data aws_vpc private_vpc {
  filter {
    name   = "tag:Name"
    values = ["*default*"]
  }
}

data aws_subnet_ids private {
  vpc_id = data.aws_vpc.private_vpc.id
}

data aws_security_group vpc_default_sg {
  vpc_id = data.aws_vpc.private_vpc.id
  name   = "default"
}

/* data "aws_route_tables" "rts" {
  vpc_id = data.aws_vpc.vpc.id

  filter {
    name   = "tag:kubernetes.io/kops/role"
    values = ["private*"]
  }
  filter {
    name   = "tag:kubernetes.io/kops/role"
    values = ["private*"]
  }
} */
