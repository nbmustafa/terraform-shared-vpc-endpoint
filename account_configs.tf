locals {

  account_id              = data.aws_caller_identity.current.account_id
  app_name                = "abc"
  application_id          = "APID001"
  cost_centre             = "CC001"
  support_group           = "krd"
  iam_name_prefix         = "abc"
  service_name            = "xyz"
  disable_api_termination = "false"
  proxy_host              = ""
  
  tags = {
    ApplicationID   = local.application_id
    ApplicationName = local.app_name
    ServiceNAme     = local.service_name
    Environment     = var.environment_name == "dev" || var.environment_name =="develop" ? "DEVELOPMENT" : upper(var.environment_name)
    EnvironmentName = var.environment_name
    SupportGroup    = local.support_group
    CostCentre      = local.cost_centre
  }

  account_configs = {
    dev = {
      
    }

    sit = {
      
    }

    prod = {
      
    }
  }
  
  account_config = local.account_configs[var.environment]
}