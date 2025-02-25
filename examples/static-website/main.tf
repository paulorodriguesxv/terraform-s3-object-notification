locals {
  domain = "my-custom-url.com"
}

data "template_file" "s3-public-policy" {
  template = file("policy.json")
  vars     = { bucket_name = local.domain }
}

module "logs" {
  source = "github.com/chgasparoto/terraform-s3-object-notification"

  name = "${local.domain}-logs"
  acl  = "log-delivery-write"
}

module "website" {
  source = "github.com/chgasparoto/terraform-s3-object-notification"

  name   = local.domain
  acl    = "public-read"
  policy = data.template_file.s3-public-policy.rendered

  versioning = {
    status = "Enabled"
  }

  filepath = "website"

  website = {
    index_document = "index.html"
    error_document = "index.html"
  }

  logging = {
    target_bucket = module.logs.name
    target_prefix = "access/"
  }
}

module "redirect" {
  source = "github.com/chgasparoto/terraform-s3-object-notification"

  name = "www.${local.domain}"
  acl  = "public-read"

  website = {
    redirect_all_requests_to = local.domain
  }
}
