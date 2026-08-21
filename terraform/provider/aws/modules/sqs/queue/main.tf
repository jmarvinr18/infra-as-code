resource "aws_sqs_queue" "this" {
  name       = var.fifo_queue ? "${var.name}.fifo" : var.name
  fifo_queue = var.fifo_queue

  content_based_deduplication = var.fifo_queue ? var.content_based_deduplication : null

  visibility_timeout_seconds = var.visibility_timeout_seconds
  message_retention_seconds  = var.message_retention_seconds
  max_message_size           = var.max_message_size
  delay_seconds              = var.delay_seconds
  receive_wait_time_seconds  = var.receive_wait_time_seconds

  # Null falls back to the SQS-managed key, which is free. A customer-managed
  # key adds per-request KMS charges for what is usually a low-volume queue.
  kms_master_key_id                 = var.kms_master_key_id
  kms_data_key_reuse_period_seconds = var.kms_master_key_id != null ? var.kms_data_key_reuse_period_seconds : null
  sqs_managed_sse_enabled           = var.kms_master_key_id == null ? var.sqs_managed_sse_enabled : null

  # Set only on a source queue; a dead-letter queue is the target of one.
  redrive_policy = var.dead_letter_queue_arn == null ? null : jsonencode({
    deadLetterTargetArn = var.dead_letter_queue_arn
    maxReceiveCount     = var.max_receive_count
  })

  # Set only on a dead-letter queue: which source queues may redrive out of it.
  redrive_allow_policy = length(var.redrive_allow_source_queue_arns) == 0 ? null : jsonencode({
    redrivePermission = "byQueue"
    sourceQueueArns   = var.redrive_allow_source_queue_arns
  })

  tags = var.tags
}

resource "aws_sqs_queue_policy" "this" {
  count = var.policy == null ? 0 : 1

  queue_url = aws_sqs_queue.this.id
  policy    = var.policy
}
