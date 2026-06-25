terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.80"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

resource "aws_s3_bucket" "crc" {
  bucket = "dmve-cloud-resume-challenge"
  tags = {
    project = "Cloud Resume Challenge"
  }
}

resource "aws_dynamodb_table" "crc" {
  name         = "dmve-cloud-resume-challenge"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    project = "Cloud Resume Challenge"
  }
}

resource "aws_lambda_function" "crc" {
  function_name = "dmve-cloud-resume-challenge"
  role          = "arn:aws:iam::374902172089:role/service-role/dmve-cloud-resume-challenge-role-sai44v93"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.13"
  filename      = "files/lambda_function.zip"
}

resource "aws_iam_role" "lambda_role" {
  name = "dmve-cloud-resume-challenge-role-sai44v93"
  path = "/service-role/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    project = "Cloud Resume Challenge"
  }
}

resource "aws_apigatewayv2_api" "crc" {
  name          = "dmve-cloud-resume-challenge-api"
  protocol_type = "HTTP"
}

resource "aws_cloudfront_distribution" "crc" {
  enabled             = true
  default_root_object = "index.html"
  comment             = "dmve-cloud-resume-challenge"
  price_class         = "PriceClass_All"
  http_version        = "http2"
  is_ipv6_enabled     = true
  web_acl_id          = "arn:aws:wafv2:us-east-1:374902172089:global/webacl/CreatedByCloudFront-96752970/cdcd206a-2052-4562-adf3-c8c37ec70cbf"


  aliases = ["resume.davidehnstrom.com"]

  origin {
    domain_name              = "dmve-cloud-resume-challenge.s3.us-east-2.amazonaws.com"
    origin_id                = "dmve-cloud-resume-challenge.s3.us-east-2.amazonaws.com-mqlb22dm32i"
    origin_access_control_id = "E1Q5NHCYTN6HW2"
  }

  default_cache_behavior {
    target_origin_id       = "dmve-cloud-resume-challenge.s3.us-east-2.amazonaws.com-mqlb22dm32i"
    viewer_protocol_policy = "https-only"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = "arn:aws:acm:us-east-1:374902172089:certificate/0451cb4c-837d-4c02-86f7-1f996ae77bfc"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
  tags = {
    Name = "dmve-cloud-resume-challenge"
  }
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

resource "aws_acm_certificate" "crc" {
  domain_name       = "*.davidehnstrom.com"
  validation_method = "DNS"
  provider          = aws.us_east_1

  tags = {
    project = "Cloud Resume Challenge"
  }
}

resource "aws_route53_zone" "crc" {
  name    = "davidehnstrom.com"
  comment = ""
}

resource "aws_route53_record" "acm_validation" {
  zone_id = aws_route53_zone.crc.zone_id
  name    = "_10d5b02bdbff003814dc939fc5e23fce.davidehnstrom.com"
  type    = "CNAME"
  ttl     = 300
  records = ["_e662185206c3a85e5e60ed63acc562dd.jkddzztszm.acm-validations.aws."]
}

resource "aws_route53_record" "crc_a" {
  zone_id = aws_route53_zone.crc.zone_id
  name    = "resume.davidehnstrom.com"
  type    = "A"

  alias {
    name                   = "d3k55v9i9popcs.cloudfront.net"
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = false
  }
}
