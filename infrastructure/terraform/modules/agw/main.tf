resource "azurerm_public_ip" "this" {
  name                = "${var.name}-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-config"
    subnet_id = var.subnet_id
  }

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.this.id
  }
  
  # Other minimal configs
  frontend_port {
    name = "frontendPort"
    port = 80
  }

  http_listener {
    name                           = "listener"
    frontend_ip_configuration_name = "PublicIPAddress"
    frontend_port_name             = "frontendPort"
    protocol                       = "Http"
  }

  request_routing_rule {
    name               = "rule1"
    rule_type          = "Basic"
    http_listener_name = "listener"
    # Backend pools will be configured by AGIC dynamically
  }

  firewall_enabled = true
  firewall_mode    = "Prevention"
  waf_configuration {
    enabled          = true
    firewall_mode    = "Prevention"
    rule_set_type    = "OWASP"
    rule_set_version = "3.2"
  }
}

output "id" {
  value = azurerm_application_gateway.this.id
}

output "public_ip" {
  value = azurerm_public_ip.this.ip_address
}