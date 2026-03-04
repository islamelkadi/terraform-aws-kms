# Basic KMS Module Example

This example demonstrates the minimal configuration required to create a KMS key with default settings.

## Features

- Automatic key rotation enabled
- Default key policy (root account access)
- 30-day deletion window
- Standard naming and tagging

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Outputs

- `key_id` - The KMS key ID
- `key_arn` - The KMS key ARN
- `alias_name` - The KMS key alias name

## Cleanup

```bash
terraform destroy
```

Note: The key will be scheduled for deletion with a 30-day waiting period.
