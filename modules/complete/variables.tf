variable "region" {
  description = "The region where the VPN gateway and other resources are located. Example: 'ap-jakarta'."
  type        = string
  default     = "ap-jakarta"
}

variable "create" {
  type = bool
  default = true
  description = "create or not"
}

variable "bucket_name" {
  type = string
  default = ""
  description = "TODO: chang with naming convention"
}


variable "bucket" {
  type = any
  default = {}
  description = "see `tencentcloud_cos_bucket`"
}

variable "cam_policies" {
  type = any
  default = {}
  description = "see `tencentcloud_cam_policy`"
}
variable "bucket_policies" {
  type = any
  default = []
  description = "see `tencentcloud_cos_bucket_policy`"
}

variable "tags" {
  description = "A mapping of tags to assign to the bucket."
  type        = map(string)
  default     = {}
}

#variable "enable_intelligent_tiering" {
#  type = bool
#  default = false
#  description = "Enable intelligent tiering. NOTE: When intelligent tiering configuration is enabled, it cannot be turned off or modified."
#}
#variable "intelligent_tiering_days" {
#  type = number
#  default = 30
#  description = "Specifies the limit of days for standard-tier data to low-frequency data in an intelligent tiered storage configuration, with optional days of 30, 60, 90. Default value is 30."
#}
#variable "intelligent_tiering_request_frequent" {
#  type = number
#  default = 1
#  description = "Specify the access limit for converting standard layer data into low-frequency layer data in the configuration. The default value is once, which can be used in combination with the number of days to achieve the conversion effect. For example, if the parameter is set to 1 and the number of access days is 30, it means that objects with less than one visit in 30 consecutive days will be reduced from the standard layer to the low frequency layer."
#}
#variable "replica_role" {
#  type = string
#  default = null
#  description = "Request initiator identifier, format: qcs::cam::uin/<owneruin>:uin/<subuin>. NOTE: only versioning_enable is true can configure this argument."
#}
#variable "replica_rules" {
#  type = any
#  default = []
#  description = " List of replica rule. NOTE: only versioning_enable is true and replica_role set can configure this argument."
#}
#variable "acceleration_enable" {
#  type = bool
#  default = false
#  description = " Enable bucket acceleration"
#}
