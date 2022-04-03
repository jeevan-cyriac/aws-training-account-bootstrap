data "aws_region" "current" {}
data "aws_route53_zone" "jeevancyriac" {
  name = local.jeevancyriac_domain_name
}

data "aws_caller_identity" "current" {}