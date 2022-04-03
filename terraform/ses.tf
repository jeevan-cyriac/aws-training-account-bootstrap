
resource "aws_ses_domain_identity" "zone" {
  domain = data.aws_route53_zone.jeevancyriac.name
}

resource "aws_route53_record" "mx_record" {
  zone_id = data.aws_route53_zone.jeevancyriac.zone_id
  name    = local.jeevancyriac_domain_name
  type    = "MX"
  ttl     = "600"
  records = ["10 inbound-smtp.${data.aws_region.current.name}.amazonaws.com"]
}

resource "aws_route53_record" "amazonses_verification_record" {
  zone_id = data.aws_route53_zone.jeevancyriac.zone_id
  name    = "_amazonses.${aws_ses_domain_identity.zone.id}"
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity.zone.verification_token]
}

resource "aws_ses_domain_identity_verification" "zone" {
  domain = aws_ses_domain_identity.zone.id

  depends_on = [aws_route53_record.amazonses_verification_record]
}

resource "aws_ses_domain_mail_from" "zone" {
  domain           = aws_ses_domain_identity.zone.domain
  mail_from_domain = "bounce.${aws_ses_domain_identity.zone.domain}"
}

resource "aws_route53_record" "ses_mail_from_mx" {
  zone_id = data.aws_route53_zone.jeevancyriac.zone_id
  name    = aws_ses_domain_mail_from.zone.mail_from_domain
  type    = "MX"
  ttl     = "600"
  records = ["10 feedback-smtp.${data.aws_region.current.name}.amazonses.com"]
}

resource "aws_route53_record" "ses_mail_from_txt" {
  zone_id = data.aws_route53_zone.jeevancyriac.zone_id
  name    = aws_ses_domain_mail_from.zone.mail_from_domain
  type    = "TXT"
  ttl     = "300"
  records = ["v=spf1 include:amazonses.com ~all"]
}

resource "aws_ses_domain_dkim" "zone" {
  domain = aws_ses_domain_identity.zone.domain
}

resource "aws_route53_record" "amazonses_verification_record_dkim" {
  count   = 3
  zone_id = data.aws_route53_zone.jeevancyriac.zone_id
  name    = "${element(aws_ses_domain_dkim.zone.dkim_tokens, count.index)}._domainkey.${data.aws_route53_zone.jeevancyriac.name}"
  type    = "CNAME"
  ttl     = "600"
  records = ["${element(aws_ses_domain_dkim.zone.dkim_tokens, count.index)}.dkim.amazonses.com"]
}

resource "aws_ses_receipt_rule_set" "main" {
  rule_set_name = "primary-rules"
}

resource "aws_ses_active_receipt_rule_set" "main" {
  rule_set_name = aws_ses_receipt_rule_set.main.rule_set_name
}


resource "aws_ses_receipt_rule" "domain_emails" {
  name          = "jeevancyriac.com"
  rule_set_name = "primary-rules"
  enabled       = true
  scan_enabled  = true

  s3_action {
    bucket_name       = aws_s3_bucket.domain_emails.id
    object_key_prefix = "raw_emails/"
    position          = 1
  }

  depends_on = [aws_s3_bucket_policy.domain_emails]
}

resource "aws_s3_bucket" "domain_emails" {
  bucket = "emails-${local.jeevancyriac_domain_name}"
}

resource "aws_s3_bucket_policy" "domain_emails" {
  bucket = aws_s3_bucket.domain_emails.id
  policy = data.aws_iam_policy_document.s3_domain_emails.json
}

data "aws_iam_policy_document" "s3_domain_emails" {
  version = "2012-10-17"

  statement {
    sid       = "AllowSESPuts"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.domain_emails.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["ses.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:Referer"

      values = [
        local.account_id
      ]
    }
  }
}