module "endpoints" {
  source = "./modules/vpc-endpoints"

  vpc_id             = data.aws_vpc.private_vpc.id
  security_group_ids = [data.aws_security_group.vpc_default_sg.id]

  endpoints = {
    s3 = {
      # interface endpoint
      service             = "s3"
      security_group_ids  = [data.aws_security_group.vpc_default_sg.id]
      subnet_ids          = concat(sort(data.aws_subnet_ids.private.ids),)
      private_dns_enabled = false // by default is false
      tags                = { Name = "s3-vpc-endpoint" }

      domain_name         = "s3.ap-southeast-2.amazonaws.com"
      comment             = "s3.ap-southeast-2.amazonaws.com"
      vpc = [
        {
          vpc_id = data.aws_vpc.private_vpc.id
        },
      ]
    },
    /* dynamodb = {
      # gateway endpoint
      service         = "dynamodb"
      route_table_ids = ["rt-12322456", "rt-43433343", "rt-11223344"]
      tags            = { Name = "dynamodb-vpc-endpoint" }
    }, */
    sns = {
      service    = "sns"
      subnet_ids = concat(sort(data.aws_subnet_ids.private.ids),)
      tags       = { Name = "sns-vpc-endpoint" }

      domain_name         = "sns.ap-southeast-2.amazonaws.com"
      comment             = "sns.ap-southeast-2.amazonaws.com"
      vpc = [
        {
          vpc_id = data.aws_vpc.private_vpc.id
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
          vpc_id = data.aws_vpc.private_vpc.id
        },
      ]
    },
  }

  tags = local.tags
}


  /* module "service_dns_a_record" {
  source  = "nashvan/route53-module/aws"
  version = "1.2.0"

  hosted_zone = local.account_config["hosted_zone"]

  records = [
    {
      name  = "${var.environment_name}.${local.app_name}"
      type  = "A"
      alias = {
        name    = "abc-1830827336.xyz.elb.amazonaws.com"
        zone_id = "Z35SXDOTRQ7X7K"
      }
    },
    {
      name  = "${var.environment_name}.${local.app_name}"
      type  = "A"
      alias = {
        name    = "abc-1830827336.xyz.elb.amazonaws.com"
        zone_id = "Z35SXDOTRQ7X7K"
      }
    },
    {
      name  = "${var.environment_name}.${local.app_name}"
      type  = "A"
      alias = {
        name    = "abc-1830827336.xyz.elb.amazonaws.com"
        zone_id = "Z35SXDOTRQ7X7K"
      }
    },

  ]

} */
