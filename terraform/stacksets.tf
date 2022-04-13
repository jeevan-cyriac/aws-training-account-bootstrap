resource "aws_cloudformation_stack_set" "governance_readonly" {
  name             = "org-governance-readonly-role"
  permission_model = "SERVICE_MANAGED"
  auto_deployment {
    enabled                          = true
    retain_stacks_on_account_removal = true

  }
  capabilities = ["CAPABILITY_NAMED_IAM"]
  parameters = {
    MasterAccountId = local.account_id
  }

  template_body = file("${path.module}/cfn/cfn_governance_readonly_role.yml")

}

resource "aws_cloudformation_stack_set_instance" "governance_readonly" {
  deployment_targets {
    organizational_unit_ids = [data.aws_organizations_organization.main.roots[0].id]
  }
  region         = var.aws_region
  stack_set_name = aws_cloudformation_stack_set.governance_readonly.name
  # operation_preferences {
  #   failure_tolerance_count = 10
  #   max_concurrent_count = 100
  #   region_concurrency_type = "PARALLEL"

  # }
}