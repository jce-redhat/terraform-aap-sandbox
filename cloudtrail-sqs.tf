# CloudTrail + EventBridge + SQS for EC2 instance monitoring
# Captures EC2 RunInstances events and sends them to SQS for AAP EDA consumption

locals {
  # Build EventBridge event pattern for EC2 RunInstances filtering
  eventbridge_pattern = {
    source      = ["aws.ec2"]
    detail-type = ["AWS API Call via CloudTrail"]
    detail = merge(
      {
        eventName = ["RunInstances"]
        awsRegion = [var.aws_region]
      },
      length(var.monitored_instance_tags) > 0 ? {
        requestParameters = {
          tagSpecificationSet = {
            items = {
              tags = var.monitored_instance_tags
            }
          }
        }
      } : {}
    )
  }
}

# S3 bucket for CloudTrail logs
resource "aws_s3_bucket" "cloudtrail" {
  count = var.enable_cloudtrail_monitoring ? 1 : 0

  bucket        = "${lower(var.aws_name_prefix)}-cloudtrail-logs-${local.deployment_id}"
  force_destroy = true

  tags = local.aws_tags
}

resource "aws_s3_bucket_lifecycle_configuration" "cloudtrail" {
  count = var.enable_cloudtrail_monitoring ? 1 : 0

  bucket = aws_s3_bucket.cloudtrail[0].id

  rule {
    id     = "delete-old-logs"
    status = "Enabled"

    expiration {
      days = var.cloudtrail_s3_retention_days
    }
  }
}

resource "aws_s3_bucket_policy" "cloudtrail" {
  count = var.enable_cloudtrail_monitoring ? 1 : 0

  bucket = aws_s3_bucket.cloudtrail[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.cloudtrail[0].arn
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.cloudtrail[0].arn}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# CloudTrail trail for multi-region monitoring
resource "aws_cloudtrail" "monitoring" {
  count = var.enable_cloudtrail_monitoring ? 1 : 0

  name                          = "${var.aws_name_prefix}-monitoring-${local.deployment_id}"
  s3_bucket_name                = aws_s3_bucket.cloudtrail[0].id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = true

  event_selector {
    read_write_type           = "WriteOnly"
    include_management_events = true
  }

  depends_on = [aws_s3_bucket_policy.cloudtrail]

  tags = local.aws_tags
}

# SQS queue for EC2 instance events
resource "aws_sqs_queue" "instance_events" {
  count = var.enable_cloudtrail_monitoring ? 1 : 0

  name                       = "${var.aws_name_prefix}-instance-events-${local.deployment_id}"
  message_retention_seconds  = 345600 # 4 days
  visibility_timeout_seconds = 300    # 5 minutes

  tags = local.aws_tags
}

# SQS queue policy allowing EventBridge to send messages
resource "aws_sqs_queue_policy" "instance_events" {
  count = var.enable_cloudtrail_monitoring ? 1 : 0

  queue_url = aws_sqs_queue.instance_events[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowEventBridgeToSendMessages"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.instance_events[0].arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_cloudwatch_event_rule.instance_events[0].arn
          }
        }
      }
    ]
  })
}

# EventBridge rule to capture EC2 RunInstances events
resource "aws_cloudwatch_event_rule" "instance_events" {
  count = var.enable_cloudtrail_monitoring ? 1 : 0

  name        = "${var.aws_name_prefix}-ec2-instance-events-${local.deployment_id}"
  description = "Capture EC2 RunInstances events for AAP EDA monitoring"

  event_pattern = jsonencode(local.eventbridge_pattern)

  tags = local.aws_tags
}

# EventBridge target: SQS queue
resource "aws_cloudwatch_event_target" "instance_events_sqs" {
  count = var.enable_cloudtrail_monitoring ? 1 : 0

  rule      = aws_cloudwatch_event_rule.instance_events[0].name
  target_id = "SendToSQS"
  arn       = aws_sqs_queue.instance_events[0].arn
}
