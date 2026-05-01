data "tencentcloud_user_info" "this" {}


locals {
  //TODO naming convention
  bucket_name = var.bucket_name
  bucket_id = join("", tencentcloud_cos_bucket.cos.*.id)
  bucket_url = join("", tencentcloud_cos_bucket.cos.*.cos_bucket_url)

  certs = distinct([for cert in try(var.bucket.origin_domain_rules, []): try(cert.cert_id, "") if try(cert.cert_id, "") != ""])
  cert_map = {for cert in local.certs: cert => cert}

  ssl_cert_map = { for k, certs in data.tencentcloud_ssl_certificates.all: k => certs.certificates[0].cert }
  ssl_key_map = { for k, certs in data.tencentcloud_ssl_certificates.all: k => certs.certificates[0].key}
}

data "tencentcloud_ssl_certificates" "all" {
  for_each = local.cert_map
  id = each.value
}

resource "tencentcloud_cos_bucket" "cos" {
  count = var.create ? 1 : 0

  bucket   = "${local.bucket_name}-${data.tencentcloud_user_info.this.app_id}"
  acl      = try(var.bucket.bucket_acl, "private")
  acl_body = try(var.bucket.acl_body, null)

  dynamic "cors_rules" {
    for_each = try(var.bucket.cors_rules, [])
    content {
      allowed_headers = lookup(cors_rules.value, "allowed_headers", [])
      allowed_methods = lookup(cors_rules.value, "allowed_methods", [])
      allowed_origins = lookup(cors_rules.value, "allowed_origins", [])
      expose_headers  = lookup(cors_rules.value, "expose_headers", null)
      max_age_seconds = lookup(cors_rules.value, "max_age_seconds", null)
    }
  }

  encryption_algorithm = try(var.bucket.encryption_algorithm, "AES256")
  force_clean          = try(var.bucket.force_clean, false)

  dynamic "lifecycle_rules" {
    for_each = try(var.bucket.lifecycle_rules, [])
    content {
      id = try(lifecycle_rules.value.id, null)
      filter_prefix = try(lifecycle_rules.value.filter_prefix, "")

      dynamic "abort_incomplete_multipart_upload" {
        for_each = try(lifecycle_rules.value.abort_incomplete_multipart_upload, [])
        content {
          days_after_initiation = try(abort_incomplete_multipart_upload.value.days_after_initiation, 30)
        }
      }

      dynamic "expiration" {
        for_each = try(lifecycle_rules.value.expiration, [])
        content {
          date = try(expiration.value.date, null)
          days = try(expiration.value.days, null)
          delete_marker = try(expiration.value.delete_marker, null)
        }
      }

      dynamic "transition" {
        for_each = try(lifecycle_rules.value.transition, [])
        content {
          storage_class = try(transition.value.storage_class, null)
          date          = try(transition.value.date, null)
          days          = try(transition.value.days, null)
        }
      }

      dynamic "non_current_expiration" {
        for_each = try(lifecycle_rules.value.non_current_expiration, [])
        content {
          non_current_days = try(non_current_expiration.value.non_current_days, null)
        }
      }

      dynamic "non_current_transition" {
        for_each = try(lifecycle_rules.value.non_current_transition, [])
        content {
          storage_class    = try(non_current_transition.value.storage_class, null)
          non_current_days = try(non_current_transition.value.non_current_days, null)
        }
      }
    }
  }

  log_enable        = try(var.bucket.log_enable, false)
  log_prefix        = try(var.bucket.log_prefix, "")
  log_target_bucket = try(var.bucket.log_target_bucket, "")

  multi_az = try(var.bucket.multi_az, false)

  dynamic "origin_domain_rules" {
    for_each = try(var.bucket.origin_domain_rules, [])
    content {
      domain = lookup(origin_domain_rules.value, "domain", "")
      status = lookup(origin_domain_rules.value, "status", "ENABLED")
      type   = lookup(origin_domain_rules.value, "type", "REST")
    }
  }

  dynamic "origin_pull_rules" {
    for_each = try(var.bucket.origin_pull_rules, [])
    content {
      host                = lookup(origin_pull_rules.value, "host", "")
      priority            = lookup(origin_pull_rules.value, "priority", 0)
      custom_http_headers = lookup(origin_pull_rules.value, "custom_http_headers", null)
      follow_http_headers = lookup(origin_pull_rules.value, "follow_http_headers", null)
      follow_query_string = lookup(origin_pull_rules.value, "follow_query_string", false)
      follow_redirection  = lookup(origin_pull_rules.value, "follow_redirection", false)
      prefix              = lookup(origin_pull_rules.value, "prefix", null)
      protocol            = lookup(origin_pull_rules.value, "protocol", null)
      sync_back_to_source = lookup(origin_pull_rules.value, "back_to_source_mode", null)  == null ? lookup(origin_pull_rules.value, "sync_back_to_source", false) : null
      back_to_source_mode = lookup(origin_pull_rules.value, "back_to_source_mode", null) # "Proxy", "Mirror", "Redirect"
      http_redirect_code = lookup(origin_pull_rules.value, "back_to_source_mode", null) == "Redirect" ?  lookup(origin_pull_rules.value, "http_redirect_code", "302") : null
    }
  }

  versioning_enable = try(var.bucket.versioning_enable, false)

  enable_intelligent_tiering = try(var.bucket.enable_intelligent_tiering, false)
  intelligent_tiering_days = try(var.bucket.enable_intelligent_tiering, false) ? try(var.bucket.intelligent_tiering_days, 30) : null
  intelligent_tiering_request_frequent = try(var.bucket.enable_intelligent_tiering, false) ? try(var.bucket.intelligent_tiering_request_frequent, 1) : null

  replica_role = try(var.bucket.replica_role, null)

  dynamic "replica_rules" {
    for_each = try(var.bucket.replica_role, null) != null && try(var.bucket.versioning_enable, false) ? try(var.bucket.replica_rules, []) : []
    content {
      id = try(replica_rules.value.id, null)
      prefix = try(replica_rules.value.prefix, null)
      destination_bucket = try(replica_rules.value.destination_bucket, null)
      status             = try(replica_rules.value.status, null)
      destination_storage_class = try(replica_rules.value.destination_storage_class, null)
    }
  }

  acceleration_enable = try(var.bucket.acceleration_enable, false)

  dynamic "website" {
    for_each = try(var.bucket.website, [])
    content {
      error_document = lookup(website.value, "error_document", null)
      index_document = lookup(website.value, "index_document", null)
      redirect_all_requests_to = lookup(website.value, "redirect_all_requests_to", null)
      dynamic routing_rules {
        for_each = lookup(website.value, "routing_rules", []) == [] ? []: [1]
        content {
          dynamic "rules" {
            for_each = lookup(website.value, "routing_rules", [])
            content {
              condition_error_code        = lookup(rules.value, "condition_error_code", "")
              condition_prefix            = lookup(rules.value, "condition_prefix", "")
              redirect_protocol           = lookup(rules.value, "redirect_protocol", "")
              redirect_replace_key_prefix = lookup(rules.value, "redirect_replace_key_prefix", "")
              redirect_replace_key        = lookup(rules.value, "redirect_replace_key", "")
            }
          }
        }
      }
    }
  }

  tags = var.tags
}


resource "tencentcloud_cam_policy" "cam_policies" { // https://cloud.tencent.com/document/product/436/31923
  for_each = var.cam_policies
  //TODO
  name        = each.value.name // ForceNew
  document = each.value.document
#  document    = <<EOF
#{
#    "version": "2.0",
#    "statement": [
#        {
#            "effect": "allow",
#            "action": [
#                "cos:*"
#            ],
#            "resource": [
#                "qcs::cos::uid/${data.tencentcloud_user_info.this.app_id}:${each.value.bucket_name}-${data.tencentcloud_user_info.this.app_id}/*"
#            ]
#        }
#    ]
#}
#EOF
  description = each.value.description
}



resource "tencentcloud_cos_bucket_policy" "bucket_policies" {
  depends_on = [tencentcloud_cos_bucket.cos]
  count = length(var.bucket_policies) > 0 ? 1 : 0
  bucket     = "${local.bucket_name}-${data.tencentcloud_user_info.this.app_id}"

  policy = jsonencode(
    {
      "Statement" : [
        for policy in var.bucket_policies : {
          Action : policy.Action,
          Effect : try(policy.Effect, "Allow"),
          Principal : policy.Principal,
          Resource : [
            for path in try(policy.paths, []):
            "qcs::cos:${policy.region}:uid/${data.tencentcloud_user_info.this.app_id}:${var.bucket_name}-${data.tencentcloud_user_info.this.app_id}/${path}"
          ],
          Condition : try(policy.Condition, []) == {} ? null : try(policy.Condition, []),
        }
      ],
      "version" : "2.0"
    }
  )
}

resource "tencentcloud_cos_bucket_domain_certificate_attachment" "cert_attachments" {
  count = length(try(var.bucket.origin_domain_rules, []))
  bucket = tencentcloud_cos_bucket.cos[0].id

  domain_certificate {
    domain = lookup(var.bucket.origin_domain_rules[count.index], "domain", "")
    certificate {
      cert_type = lookup(var.bucket.origin_domain_rules[count.index], "cert_type", "")
      custom_cert {
        cert = lookup(local.ssl_cert_map, lookup(var.bucket.origin_domain_rules[count.index], "cert_id", "NOT_SPECIFIED"), lookup(var.bucket.origin_domain_rules[count.index], "cert", ""))
        private_key = lookup(local.ssl_key_map, lookup(var.bucket.origin_domain_rules[count.index], "cert_id", "NOT_SPECIFIED"), lookup(var.bucket.origin_domain_rules[count.index], "private_key", ""))
        cert_id = lookup(var.bucket.origin_domain_rules[count.index], "cert_id", null)
      }
    }
  }
}