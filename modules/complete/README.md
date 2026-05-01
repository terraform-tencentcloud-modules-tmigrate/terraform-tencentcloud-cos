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


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12 |
| <a name="requirement_tencentcloud"></a> [tencentcloud](#requirement\_tencentcloud) | >1.78.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_tencentcloud"></a> [tencentcloud](#provider\_tencentcloud) | >1.78.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [tencentcloud_cam_policy.cam_policies](https://registry.terraform.io/providers/tencentcloudstack/tencentcloud/latest/docs/resources/cam_policy) | resource |
| [tencentcloud_cos_bucket.cos](https://registry.terraform.io/providers/tencentcloudstack/tencentcloud/latest/docs/resources/cos_bucket) | resource |
| [tencentcloud_cos_bucket_policy.bucket_policies](https://registry.terraform.io/providers/tencentcloudstack/tencentcloud/latest/docs/resources/cos_bucket_policy) | resource |
| [tencentcloud_user_info.this](https://registry.terraform.io/providers/tencentcloudstack/tencentcloud/latest/docs/data-sources/user_info) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket"></a> [bucket](#input\_bucket) | see `tencentcloud_cos_bucket` | `any` | `{}` | no |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | TODO: chang with naming convention | `string` | `""` | no |
| <a name="input_bucket_policies"></a> [bucket\_policies](#input\_bucket\_policies) | see `tencentcloud_cos_bucket_policy` | `any` | `[]` | no |
| <a name="input_cam_policies"></a> [cam\_policies](#input\_cam\_policies) | see `tencentcloud_cam_policy` | `any` | `{}` | no |
| <a name="input_create"></a> [create](#input\_create) | create or not | `bool` | `true` | no |
| <a name="input_region"></a> [region](#input\_region) | The region where the VPN gateway and other resources are located. Example: 'ap-jakarta'. | `string` | `"ap-jakarta"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the bucket. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_id"></a> [bucket\_id](#output\_bucket\_id) | n/a |
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | n/a |
| <a name="output_bucket_url"></a> [bucket\_url](#output\_bucket\_url) | n/a |
