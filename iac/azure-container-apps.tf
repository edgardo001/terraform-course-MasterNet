resource "azurerm_container_app" "app" {
  name                         = "nu-masternet-dev-eus-aca"
  resource_group_name          = azurerm_resource_group.my-nu-masternet-dev-eus-rg.name
  container_app_environment_id = azurerm_container_app_environment.my-nu-masternet-dev-eus-acae.id
  revision_mode                = "Multiple"

  # --- Stub mínimo solo para crear la CA (Terraform la "posee", pero no la configura a detalle)
  template {
    min_replicas = 1
    max_replicas = 1

    container {
      name   = "stub"
      image  = "mcr.microsoft.com/k8se/quickstart:latest"
      cpu    = 0.25
      memory = "0.5Gi"
      # sin env ni probes
    }
  }

  # IMPORTANTE: quickstart escucha en 80 → deja 80 aquí para que cree saludable.
  ingress {
    external_enabled           = true
    allow_insecure_connections = false
    target_port                = 80

    traffic_weight {
      latest_revision = true
      percentage      = 100
      label           = "primary"
    }
  }

  # ⛔️ Terraform NO “revertirá” lo que cambie tu pipeline:
  lifecycle {
    ignore_changes = [
      template,   # contenedores, env vars, probes, cpu/mem…
      ingress,    # target_port, rules…
      registry,   # pull config
      secret,     # secretos que ponga el pipeline
    ]
  }

  tags = {
    environment = var.env_id
    src         = var.src_key
  }
}

# resource "azurerm_container_app" "app" {
#   container_app_environment_id = azurerm_container_app_environment.my-nu-masternet-dev-eus-acae.id
#   name                         = "nu-masternet-dev-eus-aca"
#   resource_group_name          = azurerm_resource_group.my-nu-masternet-dev-eus-rg.name
#   revision_mode                = "Multiple"

#   template {
#     min_replicas = 1
#     max_replicas = 3

#     container {
#       cpu    = 0.25
#       image  = "mcr.microsoft.com/k8se/quickstart:latest"
#       memory = "0.5Gi"
#       name   = "nu-masternet-dev-eus-app"
#     }

#   }

#   ingress {
#     allow_insecure_connections = false
#     external_enabled           = true
#     target_port                = 8080

#     traffic_weight {
#       percentage      = 100
#       label           = "primary"
#       latest_revision = true
#     }

#   }

#   tags = {
#     environment = var.env_id
#     src         = var.src_key
#   }


# }
