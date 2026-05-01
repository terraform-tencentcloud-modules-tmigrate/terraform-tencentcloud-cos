
terraform {
  source = "../../modules/complete"
}


locals {
  region = "ap-singapore"
  well-known-cidrs = [
  ]
  tags = {
    created: "terraform"
  }
}


inputs =  {
  tags = local.tags
  bucket_name = "test-origin"
  bucket = {
    bucket_acl : "public-read"
    multi_az : true
    versioning_enable : true
    replica_role : null
    replica_rules : null
    log_enable : false
    encryption_algorithm : ""
    force_clean : true
    origin_pull_rules = [
      {
        host                = "abc.com"
        priority            = 100
        custom_http_headers = null
        follow_http_headers = null
        follow_query_string = false
        follow_redirection  = false
        prefix              = "asdf"
        protocol            = "HTTP"
        # This parameter is deprecated. Use back_to_source_mode instead, which supports more modes.
#         sync_back_to_source = true # ture = "Mirror", false = "Proxy"
        back_to_source_mode = "Mirror"
#        back_to_source_mode = "Redirect" # "Mirror", "Proxy"
#        http_redirect_code = "301"
      }
    ]
  }
}