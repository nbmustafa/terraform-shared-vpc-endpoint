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
