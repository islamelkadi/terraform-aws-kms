# Security Controls Validations
# Enforces security standards based on metadata module security controls
# Supports selective overrides with documented justification

locals {
  # Use security controls if provided, otherwise use permissive defaults
  security_controls = var.security_controls != null ? var.security_controls : {
    encryption = {
      require_kms_customer_managed  = false
      require_encryption_at_rest    = false
      require_encryption_in_transit = false
      enable_kms_key_rotation       = false
    }
    logging = {
      require_cloudwatch_logs = false
      min_log_retention_days  = 1
      require_access_logging  = false
      require_flow_logs       = false
    }
    monitoring = {
      enable_xray_tracing         = false
      enable_enhanced_monitoring  = false
      enable_performance_insights = false
      require_cloudtrail          = false
    }
    compliance = {
      enable_point_in_time_recovery = false
      require_reserved_concurrency  = false
      enable_deletion_protection    = false
    }
  }

  # Apply overrides to security controls
  # Controls are enforced UNLESS explicitly overridden with justification
  key_rotation_required    = local.security_controls.encryption.enable_kms_key_rotation && !var.security_control_overrides.disable_key_rotation_requirement
  deletion_window_enforced = !var.security_control_overrides.disable_deletion_window_validation

  # Validation results
  key_rotation_validation_passed    = !local.key_rotation_required || var.enable_key_rotation
  deletion_window_validation_passed = !local.deletion_window_enforced || var.deletion_window_in_days >= 7

  # Audit trail for overrides
  has_overrides = (
    var.security_control_overrides.disable_key_rotation_requirement ||
    var.security_control_overrides.disable_deletion_window_validation
  )

  justification_provided = var.security_control_overrides.justification != ""
  override_audit_passed  = !local.has_overrides || local.justification_provided
}

# Security Controls Check Block
check "security_controls_compliance" {
  assert {
    condition     = local.key_rotation_validation_passed
    error_message = "Security control violation: KMS key rotation is required but enable_key_rotation is false. Set security_control_overrides.disable_key_rotation_requirement=true with justification if this is intentional."
  }

  assert {
    condition     = local.deletion_window_validation_passed
    error_message = "Security control violation: Deletion window must be at least 7 days but is set to ${var.deletion_window_in_days}. Set security_control_overrides.disable_deletion_window_validation=true with justification if this is intentional."
  }

  assert {
    condition     = local.override_audit_passed
    error_message = "Security control overrides detected but no justification provided. Please document the business reason in security_control_overrides.justification for audit compliance."
  }
}
