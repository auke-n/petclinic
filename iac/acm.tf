//----------------jenkins-------------------
resource "aws_acm_certificate" "jenkins-https" {
  domain_name       = "jenkins.sec.iplatinum.pro"
  validation_method = "DNS"

  tags = {
    Name = "jenkins"
  }
}

resource "aws_acm_certificate_validation" "jenkins-certificate" {
  timeouts {
    create = "5m"
  }
  certificate_arn         = aws_acm_certificate.jenkins-https.arn
  validation_record_fqdns = [for record in aws_route53_record.acm-validation1 : record.fqdn]
}

resource "aws_route53_record" "acm-validation1" {
  for_each = {
    for dvo in aws_acm_certificate.jenkins-https.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = "Z00084481U441RC0QQ500"
}

//---------------web-server--------------------
resource "aws_acm_certificate" "petclinic-https" {
  domain_name       = "petclininc.sec.iplatinum.pro"
  validation_method = "DNS"

  tags = {
    Name = "petclinic"
  }
}

resource "aws_route53_record" "acm_validation2" {
  for_each = {
    for dvo in aws_acm_certificate.petclinic-https.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = "Z00084481U441RC0QQ500"
}