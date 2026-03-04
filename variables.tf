# KMS Module Variables

# Metadata variables for consistent naming
variable "namespace" {
  description = "Namespace (organization/team name)"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod"
  }
}

variable "name" {
  description = "Name of the KMS key"
  type        = string
}

variable "attributes" {
  description = "Additional attributes for naming"
  type        = list(string)
  default     = []
}

variable "delimiter" {
  description = "Delimiter to use between name components"
  type        = string
  default     = "-"
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

# KMS specific variables
variable "description" {
  description = "Description of the KMS key"
  type        = string
}

variable "deletion_window_in_days" {
  description = "Duration in days after which the key is deleted after destruction (7-30 days)"
  type        = number
  default     = 30

  validation {
    condition     = var.deletion_window_in_days >= 7 && var.deletion_window_in_days <= 30
    error_message = "Deletion window must be between 7 and 30 days"
  }
}

variable "enable_key_rotation" {
  description = "Enable automatic key rotation"
  type        = bool
  default     = true
}

variable "multi_region" {
  description = "Create a multi-region key"
  type        = bool
  default     = false
}

variable "key_policy" {
  description = "Custom key policy JSON. If not provided, a default policy will be created"
  type        = string
  default     = null
}

variable "key_users" {
  description = "List of IAM role/user ARNs that can use the key for encryption/decryption"
  type        = list(string)
  default     = []
}

variable "key_administrators" {
  description = "List of IAM role/user ARNs that can administer the key"
  type        = list(string)
  default     = []
}

variable "service_principals" {
  description = "List of AWS service principals that can use the key (e.g., lambda.amazonaws.com, s3.amazonaws.com)"
  type        = list(string)
  default     = []
}

variable "enable_cloudwatch_logs_access" {
  description = "Allow CloudWatch Logs to use the key for log group encryption"
  type        = bool
  default     = false
}

variable "region" {
  description = "AWS region where resources will be created"
  type        = string
}

# Security controls
variable "security_controls" {
  description = "Security controls configuration from metadata module"
  type = object({
    encryption = object({
      require_kms_customer_managed  = bool
      require_encryption_at_rest    = bool
      require_encryption_in_transit = bool
      enable_kms_key_rotation       = bool
    })
    logging = object({
      require_cloudwatch_logs = bool
      min_log_retention_days  = number
      require_access_logging  = bool
      require_flow_logs       = bool
    })
    monitoring = object({
      enable_xray_tracing         = bool
      enable_enhanced_monitoring  = bool
      enable_performance_insights = bool
      require_cloudtrail          = bool
    })
    compliance = object({
      enable_point_in_time_recovery = bool
      require_reserved_concurrency  = bool
      enable_deletion_protection    = bool
    })
  })
  default = null
}

variable "security_control_overrides" {
  description = "Override specific security controls with documented justification"
  type = object({
    disable_key_rotation_requirement   = optional(bool, false)
    disable_deletion_window_validation = optional(bool, false)
    justification                      = optional(string, "")
  })
  default = {
    disable_key_rotation_requirement   = false
    disable_deletion_window_validation = false
    justification                      = ""
  }
}
