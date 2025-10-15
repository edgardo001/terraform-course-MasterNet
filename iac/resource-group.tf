resource "azurerm_resource_group" "my-nu-masternet-dev-eus-rg" {
    location = var.location
    name = "nu-masternet-dev-eus-rg"

    tags = {
        environment = var.env_id
        src = var.src_key
    }
}
