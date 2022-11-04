variable "source_bucket_name" {
  description = "Name of bucket to be replicated"
  type        = string
}

variable "destination_bucket_name" {
  description = "Name of destination bucket"
  type        = string
}

variable "iam_role_name" {
  description = "Name of iam role"
  type        = string
  default     = "s3-bucket-replication"
}

variable "iam_policy_name" {
  description = "Name of iam policy"
  type        = string
  default     = "s3-bucket-replication"
}
