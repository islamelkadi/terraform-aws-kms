# Basic Example Variables

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "namespace" {
  description = "Namespace (organization/team name)"
  type        = string
  default     = "example"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "name" {
  description = "Name of the KMS key"
  type        = string
  default     = "example-key"
}

variable "description" {
  description = "Description of the KMS key"
  type        = string
  default     = "Example KMS key for testing"
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default = {
    Example = "basic"
  }
}
