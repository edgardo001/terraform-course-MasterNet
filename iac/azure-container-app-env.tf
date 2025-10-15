resource "azurerm_container_app_environment" "my-nu-masternet-dev-eus-acae" {
    location = azurerm_resource_group.my-nu-masternet-dev-eus-rg.location
    name = "nu-masternet-dev-eus-acae"
    resource_group_name = azurerm_resource_group.my-nu-masternet-dev-eus-rg.name
    log_analytics_workspace_id = azurerm_log_analytics_workspace.my-nu-masternet-eus-law.id

    tags = {
        environment = var.env_id
        src = var.src_key
    }
}