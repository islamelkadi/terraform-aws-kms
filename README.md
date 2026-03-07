# Terraform AWS KMS Module

A reusable Terraform module for creating AWS KMS Customer Managed Keys (CMK) with AWS Security Hub compliance (FSBP, CIS, NIST 800-53, NIST 800-171, PCI DSS), automatic key rotation, and flexible security control overrides.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Security](#security)
- [Features](#features)
- [Usage](#usage)
- [Requirements](#requirements)
- [MCP Servers](#mcp-servers)
- [License](#license)


## Prerequisites

This module is designed for macOS. The following must already be installed on your machine:
- Python 3 and pip
- [Kiro](https://kiro.dev) and Kiro CLI
- [Homebrew](https://brew.sh)

To install the remaining development tools, run:

```bash
make bootstrap
```

This will install/upgrade: tfenv, Terraform (via tfenv), tflint, terraform-docs, checkov, and pre-commit.



## Security

### Security Controls

This module implements AWS Security Hub compliance with an extensible override system.

### Available Security Control Overrides

| Override Flag | Description | Common Justification |
|--------------|-------------|---------------------|
| `disable_key_rotation_requirement` | Disables automatic key rotation | "Imported key material, manual rotation process" |
| `disable_deletion_window_validation` | Allows shorter deletion window | "Development key, faster teardown needed" |

### Security Best Practices

**Production Keys:**
- Enable automatic key rotation (365 days)
- Set deletion window to 30 days (maximum)
- Define key administrators and users explicitly
- Enable CloudWatch Logs access for log encryption
- Use multi-region keys for disaster recovery

**Development Keys:**
- Key rotation still recommended
- Shorter deletion window acceptable (7-14 days)

### Environment-Based Security Controls

Security controls are automatically applied based on the environment through the [terraform-aws-metadata](https://github.com/islamelkadi/terraform-aws-metadata?tab=readme-ov-file#security-profiles){:target="_blank"} module's security profiles:

| Control | Dev | Staging | Prod |
|---------|-----|---------|------|
| KMS customer-managed keys | Optional | Required | Required |
| Key rotation | Recommended | Required | Required |
| Deletion window | 7 days | 14-30 days | 30 days |
| CloudWatch Logs access | Optional | Recommended | Required |

For full details on security profiles and how controls vary by environment, see the <a href="https://github.com/islamelkadi/terraform-aws-metadata?tab=readme-ov-file#security-profiles" target="_blank">Security Profiles</a> documentation.

### Security Best Practices

**Production Keys:**
- Enable automatic key rotation (365 days)
- Set deletion window to 30 days (maximum)
- Define key administrators and users explicitly
- Enable CloudWatch Logs access for log encryption
- Use multi-region keys for disaster recovery

**Development Keys:**
- Key rotation still recommended
- Shorter deletion window acceptable (7-14 days)
## Features

- KMS customer-managed key (CMK)
- Automatic key rotation
- Configurable deletion window (7-30 days)
- Key policy management
- Multi-region key support
- CloudWatch Logs integration
- Security controls integration

## Usage Examples

### Basic Example

```hcl
module "kms_key" {
  source = "github.com/islamelkadi/terraform-aws-kms?ref=v1.0.0"
  
  namespace   = "example"
  environment = "prod"
  name        = "data-encryption"
  region      = "us-east-1"
  
  description = "KMS key for encrypting sensitive data"
  
  key_administrators = [
    "arn:aws:iam::123456789012:role/admin"
  ]
  
  key_users = [
    module.lambda.role_arn,
    module.s3.role_arn
  ]
  
  tags = {
    Project = "CorporateActions"
  }
}
```

### Production Key with Security Controls

```hcl
module "kms_key" {
  source = "github.com/islamelkadi/terraform-aws-kms?ref=v1.0.0"
  
  security_controls = module.metadata.security_controls
  
  namespace   = "example"
  environment = "prod"
  name        = "corporate-actions-encryption"
  region      = "us-east-1"
  
  description = "KMS key for Corporate Actions application encryption"
  
  # Automatic key rotation enabled
  enable_key_rotation = true
  
  # Maximum deletion window for production
  deletion_window_in_days = 30
  
  # Key administrators
  key_administrators = [
    "arn:aws:iam::123456789012:role/SecurityAdmin",
    "arn:aws:iam::123456789012:role/InfraAdmin"
  ]
  
  # Key users (services that encrypt/decrypt)
  key_users = [
    module.lambda.role_arn,
    module.rds.role_arn,
    module.s3.role_arn,
    module.dynamodb.role_arn
  ]
  
  # Allow CloudWatch Logs to use key
  enable_cloudwatch_logs_access = true
  
  # Service principals
  service_principals = [
    "lambda.amazonaws.com",
    "s3.amazonaws.com",
    "dynamodb.amazonaws.com"
  ]
  
  tags = {
    Project    = "CorporateActions"
    DataClass  = "Confidential"
    Compliance = "PCI-DSS"
  }
}
```

### Multi-Region Key for Disaster Recovery

```hcl
module "kms_key_primary" {
  source = "github.com/islamelkadi/terraform-aws-kms?ref=v1.0.0"
  
  security_controls = module.metadata.security_controls
  
  namespace   = "example"
  environment = "prod"
  name        = "multi-region-encryption"
  region      = "us-east-1"
  
  description = "Multi-region KMS key for disaster recovery"
  
  # Enable multi-region
  multi_region = true
  
  enable_key_rotation     = true
  deletion_window_in_days = 30
  
  key_administrators = [
    "arn:aws:iam::123456789012:role/SecurityAdmin"
  ]
  
  key_users = [
    module.lambda.role_arn
  ]
  
  tags = {
    Project = "CorporateActions"
    DR      = "Enabled"
  }
}

# Replica in secondary region
module "kms_key_replica" {
  source = "github.com/islamelkadi/terraform-aws-kms?ref=v1.0.0"
  
  providers = {
    aws = aws.us-east-1
  }
  
  namespace   = "example"
  environment = "prod"
  name        = "multi-region-encryption-replica"
  region      = "us-east-1"
  
  description = "Replica of multi-region KMS key"
  
  # Reference primary key
  primary_key_arn = module.kms_key_primary.key_arn
  
  tags = {
    Project = "CorporateActions"
    DR      = "Replica"
  }
}
```


## MCP Servers

This module includes two [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) servers configured in `.kiro/settings/mcp.json` for use with Kiro:

| Server | Package | Description |
|--------|---------|-------------|
| `aws-docs` | `awslabs.aws-documentation-mcp-server@latest` | Provides access to AWS documentation for contextual lookups of service features, API references, and best practices. |
| `terraform` | `awslabs.terraform-mcp-server@latest` | Enables Terraform operations (init, validate, plan, fmt, tflint) directly from the IDE with auto-approved commands for common workflows. |

Both servers run via `uvx` and require no additional installation beyond the [bootstrap](#prerequisites) step.

<!-- BEGIN_TF_DOCS -->


## Usage

```hcl
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
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.14.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.34 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.34 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_metadata"></a> [metadata](#module\_metadata) | github.com/islamelkadi/terraform-aws-metadata | v1.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_kms_alias.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_iam_policy_document.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_attributes"></a> [attributes](#input\_attributes) | Additional attributes for naming | `list(string)` | `[]` | no |
| <a name="input_deletion_window_in_days"></a> [deletion\_window\_in\_days](#input\_deletion\_window\_in\_days) | Duration in days after which the key is deleted after destruction (7-30 days) | `number` | `30` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to use between name components | `string` | `"-"` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the KMS key | `string` | n/a | yes |
| <a name="input_enable_cloudwatch_logs_access"></a> [enable\_cloudwatch\_logs\_access](#input\_enable\_cloudwatch\_logs\_access) | Allow CloudWatch Logs to use the key for log group encryption | `bool` | `false` | no |
| <a name="input_enable_key_rotation"></a> [enable\_key\_rotation](#input\_enable\_key\_rotation) | Enable automatic key rotation | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (dev, staging, prod) | `string` | n/a | yes |
| <a name="input_key_administrators"></a> [key\_administrators](#input\_key\_administrators) | List of IAM role/user ARNs that can administer the key | `list(string)` | `[]` | no |
| <a name="input_key_policy"></a> [key\_policy](#input\_key\_policy) | Custom key policy JSON. If not provided, a default policy will be created | `string` | `null` | no |
| <a name="input_key_users"></a> [key\_users](#input\_key\_users) | List of IAM role/user ARNs that can use the key for encryption/decryption | `list(string)` | `[]` | no |
| <a name="input_multi_region"></a> [multi\_region](#input\_multi\_region) | Create a multi-region key | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the KMS key | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace (organization/team name) | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region where resources will be created | `string` | n/a | yes |
| <a name="input_security_control_overrides"></a> [security\_control\_overrides](#input\_security\_control\_overrides) | Override specific security controls with documented justification | <pre>object({<br/>    disable_key_rotation_requirement   = optional(bool, false)<br/>    disable_deletion_window_validation = optional(bool, false)<br/>    justification                      = optional(string, "")<br/>  })</pre> | <pre>{<br/>  "disable_deletion_window_validation": false,<br/>  "disable_key_rotation_requirement": false,<br/>  "justification": ""<br/>}</pre> | no |
| <a name="input_security_controls"></a> [security\_controls](#input\_security\_controls) | Security controls configuration from metadata module | <pre>object({<br/>    encryption = object({<br/>      require_kms_customer_managed  = bool<br/>      require_encryption_at_rest    = bool<br/>      require_encryption_in_transit = bool<br/>      enable_kms_key_rotation       = bool<br/>    })<br/>    logging = object({<br/>      require_cloudwatch_logs = bool<br/>      min_log_retention_days  = number<br/>      require_access_logging  = bool<br/>      require_flow_logs       = bool<br/>    })<br/>    monitoring = object({<br/>      enable_xray_tracing         = bool<br/>      enable_enhanced_monitoring  = bool<br/>      enable_performance_insights = bool<br/>      require_cloudtrail          = bool<br/>    })<br/>    compliance = object({<br/>      enable_point_in_time_recovery = bool<br/>      require_reserved_concurrency  = bool<br/>      enable_deletion_protection    = bool<br/>    })<br/>  })</pre> | `null` | no |
| <a name="input_service_principals"></a> [service\_principals](#input\_service\_principals) | List of AWS service principals that can use the key (e.g., lambda.amazonaws.com, s3.amazonaws.com) | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alias_arn"></a> [alias\_arn](#output\_alias\_arn) | KMS key alias ARN |
| <a name="output_alias_name"></a> [alias\_name](#output\_alias\_name) | KMS key alias name |
| <a name="output_key_arn"></a> [key\_arn](#output\_key\_arn) | KMS key ARN |
| <a name="output_key_id"></a> [key\_id](#output\_key\_id) | KMS key ID |
| <a name="output_key_policy"></a> [key\_policy](#output\_key\_policy) | KMS key policy |
| <a name="output_tags"></a> [tags](#output\_tags) | Tags applied to the KMS key |


## License

MIT Licensed. See [LICENSE](LICENSE) for full details.
<!-- END_TF_DOCS -->

## Examples

See [example/](example/) for a complete working example with key policy configuration.

