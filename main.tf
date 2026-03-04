# KMS Module
# Creates AWS KMS Customer Managed Key with rotation enabled

resource "aws_kms_key" "this" {
  description             = var.description
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = var.enable_key_rotation
  multi_region            = var.multi_region

  policy = var.key_policy != null ? var.key_policy : data.aws_iam_policy_document.default.json

  tags = local.tags
}

# Default key policy if none provided
data "aws_iam_policy_document" "default" {
  # Root account has full access
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${module.metadata.account_id}:root"]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }

  # Allow CloudWatch Logs to use the key
  dynamic "statement" {
    for_each = var.enable_cloudwatch_logs_access ? [1] : []
    content {
      sid    = "Allow CloudWatch Logs"
      effect = "Allow"

      principals {
        type        = "Service"
        identifiers = ["logs.${module.metadata.region_name}.amazonaws.com"]
      }

      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:CreateGrant",
        "kms:DescribeKey"
      ]

      resources = ["*"]

      condition {
        test     = "ArnLike"
        variable = "kms:EncryptionContext:aws:logs:arn"
        values   = ["arn:aws:logs:${module.metadata.region_name}:${module.metadata.account_id}:*"]
      }
    }
  }

  # Allow specified services to use the key
  dynamic "statement" {
    for_each = length(var.service_principals) > 0 ? [1] : []
    content {
      sid    = "Allow AWS Services"
      effect = "Allow"

      principals {
        type        = "Service"
        identifiers = var.service_principals
      }

      actions = [
        "kms:Decrypt",
        "kms:GenerateDataKey",
        "kms:CreateGrant"
      ]

      resources = ["*"]
    }
  }

  # Allow specified IAM roles to use the key
  dynamic "statement" {
    for_each = length(var.key_users) > 0 ? [1] : []
    content {
      sid    = "Allow Key Users"
      effect = "Allow"

      principals {
        type        = "AWS"
        identifiers = var.key_users
      }

      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ]

      resources = ["*"]
    }
  }

  # Allow specified IAM roles to manage the key
  dynamic "statement" {
    for_each = length(var.key_administrators) > 0 ? [1] : []
    content {
      sid    = "Allow Key Administrators"
      effect = "Allow"

      principals {
        type        = "AWS"
        identifiers = var.key_administrators
      }

      actions = [
        "kms:Create*",
        "kms:Describe*",
        "kms:Enable*",
        "kms:List*",
        "kms:Put*",
        "kms:Update*",
        "kms:Revoke*",
        "kms:Disable*",
        "kms:Get*",
        "kms:Delete*",
        "kms:TagResource",
        "kms:UntagResource",
        "kms:ScheduleKeyDeletion",
        "kms:CancelKeyDeletion"
      ]

      resources = ["*"]
    }
  }
}

# KMS Key Alias
resource "aws_kms_alias" "this" {
  name          = "alias/${local.key_alias_name}"
  target_key_id = aws_kms_key.this.key_id
}
