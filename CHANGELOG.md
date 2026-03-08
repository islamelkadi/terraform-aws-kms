## [1.0.1](https://github.com/islamelkadi/terraform-aws-kms/compare/v1.0.0...v1.0.1) (2026-03-08)


### Bug Fixes

* add CKV_TF_1 suppression for external module metadata ([e49d32b](https://github.com/islamelkadi/terraform-aws-kms/commit/e49d32b3baf9d94ee88dc8689928e09b3db9c582))
* add skip-path for .external_modules in Checkov config ([870dca0](https://github.com/islamelkadi/terraform-aws-kms/commit/870dca0df39095f3e52e4843ac7ba0cd9f7cad37))
* address Checkov security findings ([d3b47ba](https://github.com/islamelkadi/terraform-aws-kms/commit/d3b47bab5e35dfdc60705e6fe3001436d187a3ab))
* correct .checkov.yaml format to use simple list instead of id/comment dict ([757a6c6](https://github.com/islamelkadi/terraform-aws-kms/commit/757a6c6ab954e7e6ee8eeca40fb6d069165fd2f8))
* remove skip-path from .checkov.yaml, rely on workflow-level skip_path ([ff03210](https://github.com/islamelkadi/terraform-aws-kms/commit/ff03210d25f31b3ab9717d930243c2a54cf58c28))
* update workflow path reference to terraform-security.yaml ([c386a9c](https://github.com/islamelkadi/terraform-aws-kms/commit/c386a9c938d3600bbbad52ab04c9089f798a7816))

## 1.0.0 (2026-03-07)


### ⚠ BREAKING CHANGES

* First publish - KMS Terraform module

### Features

* First publish - KMS Terraform module ([7cbf371](https://github.com/islamelkadi/terraform-aws-kms/commit/7cbf371712e4925906e4abcdab697bc68a05f3cd))
