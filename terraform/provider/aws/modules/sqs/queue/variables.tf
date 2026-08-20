variable "name" {
  description = "Queue name. The \".fifo\" suffix is appended automatically when fifo_queue is true."
  type        = string
}

variable "fifo_queue" {
  type    = bool
  default = false
}

variable "content_based_deduplication" {
  description = "FIFO only. Ignored on standard queues."
  type        = bool
  default     = false
}

variable "visibility_timeout_seconds" {
  description = "Must be at least the consuming Lambda's timeout, or the same message is delivered twice."
  type        = number
  default     = 30
}

variable "message_retention_seconds" {
  description = "How long an unconsumed message survives. 14 days is the maximum and the right default for a dead-letter queue — the point is that a failure is still there on Monday."
  type        = number
  default     = 1209600
}

variable "max_message_size" {
  type    = number
  default = 262144
}

variable "delay_seconds" {
  type    = number
  default = 0
}

variable "receive_wait_time_seconds" {
  description = "Long-poll duration. 20 cuts empty receives and their cost."
  type        = number
  default     = 20
}

variable "sqs_managed_sse_enabled" {
  description = "Encrypt with the free SQS-owned key. Ignored when kms_master_key_id is set."
  type        = bool
  default     = true
}

variable "kms_master_key_id" {
  description = "Customer-managed KMS key id or alias. Null uses the SQS-managed key."
  type        = string
  default     = null
}

variable "kms_data_key_reuse_period_seconds" {
  type    = number
  default = 300
}

variable "dead_letter_queue_arn" {
  description = "Set on a source queue to redrive failures to a DLQ. Leave null on the DLQ itself."
  type        = string
  default     = null
}

variable "max_receive_count" {
  description = "Receives before a message is moved to the DLQ. Only used when dead_letter_queue_arn is set."
  type        = number
  default     = 3
}

variable "redrive_allow_source_queue_arns" {
  description = "Set on a dead-letter queue: the source queue ARNs permitted to redrive messages back out."
  type        = list(string)
  default     = []
}

variable "policy" {
  description = "Queue policy JSON. Null leaves the default owner-only policy in place."
  type        = string
  default     = null
}

variable "tags" {
  type    = map(string)
  default = {}
}
