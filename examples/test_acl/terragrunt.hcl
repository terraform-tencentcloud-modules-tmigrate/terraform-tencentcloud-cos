
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
  bucket_name = "cos-bucket-acl-test"
  bucket = {
    bucket_acl : "public-read"
    multi_az : true
    versioning_enable : true
    replica_role : null
    replica_rules : null
    log_enable : false
    encryption_algorithm : ""
    force_clean : true
  }
  bucket_policies: [
    # # allow ip list
    {
      "Action": [
        "name/cos:*"
      ],
      "Effect": "Allow",
      "Principal": {
        "qcs": [
          "qcs::cam::anyone:anyone"
        ]
      },
      "Condition": {
        "ip_equal": {
          "qcs:ip": local.well-known-cidrs
        }
      }
      paths: [
        "path1/path2",
        "path3/path4"
      ]
      region: local.region
    }
  ]
}