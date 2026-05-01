# (Deprecated) TencentCloud COS Module for Terraform

## terraform-tencentcloud-cos

A terraform module used for create TencentCloud COS bucket.

These features of COS bucket configurations are supported:
- static web-site hosting
- access logging
- replication
- versioning
- CORS
- lifecycle rules
- origin domain rules
- origin pull settings
- acl


## Usage
-----
### Private bucket with versioning enabled
```hcl
 module "cos-bucket" {
   source      = "terraform-tencentcloud-modules/cos/tencentcloud"

   bucket_name = "my-bucket"
   acl         = "private"

   versioning = {
     enabled = true
   }
 }
```

### Bucket with access log

```hcl
 module "cos-bucket" {
   source = "terraform-tencentcloud-modules/cos/tencentcloud"

   bucket = "my-bucket"
   acl    = "private"

   # Force cleanup all objects before delete bucket
   force_clean = true

   log_enable = true  # indicate the access log of this bucket to be saved
 }
```

### This COS bucket will not be created
```
module "cos-bucket" {
  source = "terraform-tencentcloud-modules/cos/tencentcloud"

  create_bucket = false
  # ... omitted
}
```

### Bucket with domain certificate and policy attached
```
module "cos-bucket" {
  source = "terraform-tencentcloud-modules/cos/tencentcloud"

  create_bucket_policy = true 
  create_bucket_domain_certificate = true
  # ... omitted
}
```

## Examples:

- [Complete](https://github.com/terraform-tencentcloud-modules/terraform-tencent-cos/tree/master/examples/complete) - Complete COS bucket with supported features enabled


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_tencentcloud"></a> [tencentcloud](#requirement\_tencentcloud) | >= 4.9 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_tencentcloud"></a> [tencentcloud](#provider\_tencentcloud) | >= 4.9 |


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| create_bucket | Controls if COS bucket should be created. | bool | true | no
| create_bucket_domain_certificate | Controls if COS bucket domain certificate should be created. | bool | true | no
| create_bucket_policy | Controls if COS bucket policy should be created. | bool | true | no
| appid | Your appid. | string | "" | yes
| bucket_name | The name of the bucket. | string | "" | yes
| bucket_acl | Access control list for the bucket. | string | private | no
| bucket_body | The XML format of Access control list for the bucket. | string | "" | no
| cors_rules | A rule of Cross-Origin Resource Sharing for the bucket. | list | [] | no
| encryption_algorithm | The server-side encryption algorithm to the bucket. | string | AES256 | no
| force_clean | Whether to force cleanup all objects before delete bucket. | bool | false | no
| lifecycle_rules | Lifecycle rules to the bucket. | list | [] | no
| log_enable | Indicate the access log of this bucket to be saved or not. | bool | false | no
| log_prefix | The prefix log name which saves the access log of this bucket per 5 minutes. Eg. MyLogPrefix/. The log access file format is log_target_bucket/log_prefix{YYYY}/{MM}/{DD}/{time}{random}{index}.gz. Only valid when log_enable is true. | string | "" | no
| log_target_bucket | The target bucket name which saves the access log of this bucket per 5 minutes. The log access file format is log_target_bucket/log_prefix{YYYY}/{MM}/{DD}/{time}{random}{index}.gz. Only valid when log_enable is true. User must have full access on this bucket. | string | "" | no
| multi_az | Indicates whether to create a bucket of multi available zone. NOTE: If set to true, the versioning must enable. | bool | false | no
| origin_domain_rules | Bucket Origin Domain settings. | list(map(string)) | [] | no
| origin_pull_rules | Bucket Origin-Pull settings. | list | [] | no
| replica_role | Request initiator identifier, format: qcs::cam::uin/<owneruin>:uin/<subuin>. NOTE: only versioning_enable is true can configure this argument. | string | "" | no
| replica_rules | List of replica rule. NOTE: only versioning_enable is true and replica_role set can configure this argument. | list(map(string)) | [] | no
| versioning_enable | Enable bucket versioning. | bool | false | no
| website | A website object. | list(map(string)) | [] | no
| tags | A mapping of tags to assign to the bucket. | map(string) | {} | no
| domain_certificate | The certificate of specified doamin. | list | [] | no
| policy | The text of the policy. | string | "" | no

## Outputs

| Name | Description |
|------|-------------|
| bucket_id | The ID of the bucket. |
| bucket_url | The URL of this cos bucket. |
| bucket_domain_certificate_id | The ID of the bucket domain certificate. |
| bucket_policy_id | The ID of the bucket policy. |


## License

Mozilla Public License Version 2.0.
See LICENSE for full details.
