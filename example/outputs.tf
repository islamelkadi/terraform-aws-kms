# Basic Example Outputs

output "key_id" {
  description = "KMS key ID"
  value       = module.kms.key_id
}

output "key_arn" {
  description = "KMS key ARN"
  value       = module.kms.key_arn
}

output "alias_name" {
  description = "KMS key alias name"
  value       = module.kms.alias_name
}
