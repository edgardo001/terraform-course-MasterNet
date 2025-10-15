resource "azurerm_log_analytics_workspace" "my-nu-masternet-eus-law" {
    location = azurerm_resource_group.my-nu-masternet-dev-eus-rg.location
    name = "nu-masternet-${var.env_id}-eus-law"
    resource_group_name = azurerm_resource_group.my-nu-masternet-dev-eus-rg.name
    sku = "PerGB2018"
    retention_in_days = 30
}