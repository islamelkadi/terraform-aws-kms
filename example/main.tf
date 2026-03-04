# Basic KMS Module Example

module "kms" {
  source = "../"

  namespace   = var.namespace
  environment = var.environment
  name        = var.name
  description = var.description
  region      = var.region
  # Use default settings (rotation enabled, 30-day deletion window)

  tags = var.tags
}
