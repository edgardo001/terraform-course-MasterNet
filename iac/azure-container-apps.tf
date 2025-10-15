resource "azurerm_container_app" "app" {
  container_app_environment_id = azurerm_container_app_environment.my-nu-masternet-dev-eus-acae.id
  name                         = "nu-masternet-dev-eus-aca"
  resource_group_name          = azurerm_resource_group.my-nu-masternet-dev-eus-rg.name
  revision_mode                = "Multiple"

  template {
    min_replicas = 1
    max_replicas = 3

    container {
      cpu    = 0.25
      image  = "mcr.microsoft.com/k8se/quisckstart:latest"
      memory = "0.5Gi"
      name   = "nu-masternet-dev-eus-app"
    }

  }

  ingress {
    allow_insecure_connections = false
    external_enabled           = true
    target_port                = 8080

    traffic_weight {
      percentage      = 100
      label           = "primary"
      latest_revision = true
    }

  }

  tags = {
    environment = var.env_id
    src         = var.src_key
  }


}
