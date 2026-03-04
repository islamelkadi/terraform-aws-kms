# Local values for naming and tagging

locals {
  # Construct key alias name from components
  name_parts = compact(concat(
    [var.namespace],
    [var.environment],
    [var.name],
    var.attributes
  ))

  key_alias_name = join(var.delimiter, local.name_parts)

  # Merge tags with defaults
  tags = merge(
    var.tags,
    module.metadata.security_tags,
    {
      Name   = local.key_alias_name
      Module = "terraform-aws-kms"
    }
  )
}
