data "azurerm_client_config" "current" {}

module "key-vault" {
  source                  = "git@github.com:hmcts/cnp-module-key-vault?ref=master"
  product                 = var.product
  env                     = var.env
  tenant_id               = data.azurerm_client_config.current.tenant_id
  object_id               = var.jenkins_AAD_objectId
  resource_group_name     = azurerm_resource_group.rg.name
  product_group_name      = var.product_group_name
  common_tags             = var.common_tags
  create_managed_identity = true
}

output "vaultName" {
  value = module.key-vault.key_vault_name
}

data "azurerm_key_vault" "s2s_vault" {
  name                = "s2s-${var.env}"
  resource_group_name = "rpe-service-auth-provider-${var.env}"
}

data "azurerm_key_vault_secret" "api_s2s_key_from_vault" {
  name         = "microservicekey-enforcement-api"
  key_vault_id = data.azurerm_key_vault.s2s_vault.id
}

resource "azurerm_key_vault_secret" "enforcement-api-s2s-secret" {
  name         = "enforcement-api-s2s-secret"
  value        = data.azurerm_key_vault_secret.api_s2s_key_from_vault.value
  key_vault_id = module.key-vault.key_vault_id
}
