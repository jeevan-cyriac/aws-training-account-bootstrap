

resource "aws_route53_record" "google_ci_domain_verification" {
  name    = local.jeevancyriac_domain_name
  zone_id = data.aws_route53_zone.jeevancyriac.zone_id
  records = ["google-site-verification=-Yw4DlpW41aX8cKA2LQ4hy8bNoWLBgMA6hDmiL5HqKA"]
  type    = "TXT"
  ttl     = "300"
}