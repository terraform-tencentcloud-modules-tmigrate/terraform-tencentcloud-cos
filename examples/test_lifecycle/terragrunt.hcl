
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
  bucket_name = "test-lifecycle"
  bucket = {
    bucket_acl : "public-read"
    multi_az : true
    versioning_enable : true
    replica_role : null
    replica_rules : null
    log_enable : false
    encryption_algorithm : ""
    force_clean : true
    lifecycle_rules = [
      {
        id            = "archive-and-10y-retention"
        filter_prefix = ""                          // Apply to all objects in the bucket.
        transition = [
          {
            days          = 30
            storage_class = "MAZ_STANDARD_IA"
          },
          {
            days          = 90
            storage_class = "MAZ_ARCHIVE"
          }
        ]
        expiration = [
          {
            days = 3650
          }
        ]
      }
    ]
  }
}