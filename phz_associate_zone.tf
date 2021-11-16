/* 
resource "aws_route53_zone" "private" {
  name = "s3.ap-southeast-2.amazonaws.com"
  
  # Private Zone required at least one VPC association at all time. 
  # this is required when we want to create a private hosted zone 
  vpc {
    vpc_id = data.aws_vpc.private_vpc.id
  }

  lifecycle {
    ignore_changes = [vpc]
  }
  tags   = local.tags
} */

# Create vpc association authorisation 
/* resource "aws_route53_vpc_association_authorization" "this" {
  vpc_id  = data.aws_vpc.vpc.id
  zone_id = aws_route53_zone.private.id
}

# Associate VPCs to 
resource "aws_route53_zone_association" "associate_vpcs" {
  #provider = "aws.alternate"
  zone_id = aws_route53_vpc_association_authorization.this.zone_id  
  vpc_id  = aws_route53_vpc_association_authorization.this.vpc_id
  
} */
