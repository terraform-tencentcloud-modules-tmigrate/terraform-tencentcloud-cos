output "logset_ids" {
  value = { for k, logset in tencentcloud_cls_logset.logset: k => logset.id }
}

output "topic_ids" {
  value = { for k, topic in tencentcloud_cls_topic.topics: k => topic.id}
}

output "index_ids" {
  value = {for k, idx in tencentcloud_cls_index.indices: k => idx.id }
}

output "bucket_id" {
  value = concat(tencentcloud_cos_bucket.cos.*.id, [""])[0]
}

output "bucket_url" {
  value = concat(tencentcloud_cos_bucket.cos.*.cos_bucket_url, [""])[0]
}

output "bucket_domain_certificate_id" {
  value = concat(tencentcloud_cos_bucket_domain_certificate_attachment.cos_bucket_domain_certificate.*.id, [""])[0]
}

output "bucket_policy_id" {
  value = concat(tencentcloud_cos_bucket_policy.cos_policy.*.id, [""])[0]
}
