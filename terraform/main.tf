terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.0"
    }
  }

  backend "s3" {
    bucket = "tarun-terraform-state-bucket-001"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

module "website_bucket" {
  source = "./modules/s3"

  bucket_name = var.website_bucket_name
  tags        = var.common_tags
}

module "logging_bucket" {
  source = "./modules/s3"

  bucket_name = var.logging_bucket_name
  tags        = var.common_tags
}

module "cloudfront" {
  source = "./modules/cloudfront"

  bucket_domain_name = module.website_bucket.bucket_regional_domain_name
  bucket_arn         = module.website_bucket.bucket_arn
}

data "aws_iam_policy_document" "website_bucket_policy" {
  statement {
    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${module.website_bucket.bucket_arn}/*"
    ]

    principals {
      type = "Service"
      identifiers = [
        "cloudfront.amazonaws.com"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values = [
        "${module.cloudfront.distribution_arn}"
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "website_bucket_policy" {
  bucket = module.website_bucket.bucket_id
  policy = data.aws_iam_policy_document.website_bucket_policy.json
}