module "vpc" {
  source = "./modules/vpc"

  name = "private"
  cidr = "10.0.0.0/16" # 10.0.0.0/8 is reserved for EC2-Classic

  azs                 = ["${local.region}a", "${local.region}b", "${local.region}c"]
  private_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  /* intra_subnets       = ["20.10.51.0/24", "20.10.52.0/24", "20.10.53.0/24"] */

  create_database_subnet_group = false

  manage_default_route_table = true
  default_route_table_tags   = { DefaultRouteTable = true }

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_classiclink             = true
  enable_classiclink_dns_support = true

  /* enable_nat_gateway = true
  single_nat_gateway = true */

  customer_gateways = {
    IP1 = {
      bgp_asn     = 65112
      ip_address  = "120.21.181.195"
      device_name = "some_name"
    },
    /* IP2 = {
      bgp_asn    = 65112
      ip_address = "5.6.7.8"
    } */
  }

  /* enable_vpn_gateway = true */

  enable_dhcp_options              = true
  dhcp_options_domain_name         = "service.consul"
  dhcp_options_domain_name_servers = ["127.0.0.1", "10.0.0.2"]

  # Default security group - ingress/egress rules cleared to deny all
  manage_default_security_group  = true
  default_security_group_ingress = []
  default_security_group_egress  = []

  # VPC Flow Logs (Cloudwatch log group and IAM role will be created)
  /* enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 60 */

  tags = local.tags
}

module "endpoints" {
  source = "./modules/vpc-endpoints"

  vpc_id             = module.vpc.vpc_id
  security_group_ids = [data.aws_security_group.vpc_default_sg.id]

  endpoints = {
    s3 = {
      # interface endpoint
      service             = "s3"
      security_group_ids  = [data.aws_security_group.vpc_default_sg.id]
      subnet_ids          = concat(sort(data.aws_subnet_ids.private.ids),)
      private_dns_enabled = false
      tags                = { Name = "s3-vpc-endpoint" }

      domain_name         = "s3.ap-southeast-2.amazonaws.com"
      comment             = "s3.ap-southeast-2.amazonaws.com"
      vpc = [
        {
          vpc_id = module.vpc.vpc_id
        },
      ]
    },
    sns = {
      service    = "sns"
      subnet_ids = concat(sort(data.aws_subnet_ids.private.ids),)
      tags       = { Name = "sns-vpc-endpoint" }

      domain_name         = "sns.ap-southeast-2.amazonaws.com"
      comment             = "sns.ap-southeast-2.amazonaws.com"
      vpc = [
        {
          vpc_id = module.vpc.vpc_id
        },
      ]
    },
    sqs = {
      service             = "sqs"
      private_dns_enabled = false 
      security_group_ids  = [data.aws_security_group.vpc_default_sg.id]
      subnet_ids          = concat(sort(data.aws_subnet_ids.private.ids),)
      tags                = { Name = "sqs-vpc-endpoint" }

      domain_name         = "sqs.ap-southeast-2.amazonaws.com"
      comment             = "sqs.ap-southeast-2.amazonaws.com"
      vpc = [
        {
          vpc_id = module.vpc.vpc_id
        },
      ]
    },
  }

  tags = local.tags
}

module "tgw" {
  source = "./modules/tgw"

  name            = "my-tgw"
  description     = "My TGW shared with several other AWS accounts"
  amazon_side_asn = 64532

  enable_auto_accept_shared_attachments = true # When "true" there is no need for RAM resources if using multiple AWS accounts

  vpc_attachments = {
    vpc1 = {
      vpc_id     = module.vpc.vpc_id
      subnet_ids = data.aws_subnet_ids.private.ids

      tgw_routes = [
        {
          destination_cidr_block = "10.0.0.0/16"
        },
        {
          blackhole              = true
          destination_cidr_block = "10.0.0.0/16"
        }
      ]
    },
  }

  /* ram_allow_external_principals = true
  ram_principals                = [307990089504] */

  tags = local.tags
}
