# tencentcloud_cos

Tencent Cloud Object Storage (COS) is a distributed storage service that enables you to store any amount of data from anywhere via HTTP/HTTPS protocols. 
COS has no restrictions on data structure or format. It also has no bucket size limit and partition management, making it suitable for virtually any use case, such as data delivery,
data processing, and data lakes. COS provides a web-based console, multi-language SDKs and APIs, command line tool, and graphical tools. It works well with Amazon S3 APIs, allowing you to quickly access community tools and plugins.

COS:

Reference: https://www.tencentcloud.com/document/product/436

## usage
```hcl


terraform {
  source = "../.."
}


locals {
  region = "ap-singapore"
  bucket_name = "cos-bucket-test-1"

  well-known-cidrs = [
    "10.0.0.0/24",
  ]
  tags = {
    created: "terraform"
  }

  uin = "xx"
  backup_uin = "xx"

  replica_role = format("qcs::cam::uin/%s:uin/%s", local.uin, local.backup_uin)
  replica_destination_bucket = "qcs::cos:ap-singapore::test-rep-xx"
}


inputs =  {
  tags = local.tags
  bucket_name = local.bucket_name
  bucket = {
    bucket_acl : "private"
    multi_az : true
    versioning_enable : true
    replica_role : null
    replica_rules : null
    log_enable : false
    encryption_algorithm : ""
    force_clean : true

    abort_incomplete_multipart_upload = [
      {
        abort_incomplete_multipart_upload = 45
      }]
    acceleration_enable = true
    enable_intelligent_tiering = true
    replica_role = local.replica_role
    replica_rules = [
      {
        id = "id1"
        prefix = "pre1"
        destination_bucket = local.replica_destination_bucket
        status             = "Enabled"
        destination_storage_class = "Standard" // STANDARD, INTELLIGENT_TIERING, STANDARD_IA
      }
    ]
  }
  bucket_policies = [
    # allow ip list
    {
      "Action": [
        "name/cos:HeadBucket",
        "name/cos:GetObject",
        "name/cos:HeadObject",
        "name/cos:OptionsObject"
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
    },
    # allow replica
    {
      "Action": [
        "name/cos:HeadObject",
        "name/cos:OptionsObject",
        "name/cos:GetObject"
      ],
      "Effect": "Allow",
      "Principal": {
        "qcs": [
          local.replica_role
        ]
      }
      paths: [
        "*"
      ]
      region: local.region
    },
    # as teo backend
    {
      "Action": [
        "name/cos:HeadObject",
        "name/cos:OptionsObject",
        "name/cos:GetObject"
      ],
      "Effect": "Allow",
      "Principal": {
        "qcs": [
          "qcs::cam::uin/${local.uin}:service/edge_one"
        ]
      }
      paths: [
        "*"
      ]
      region: local.region
    }
  ]
}

```


