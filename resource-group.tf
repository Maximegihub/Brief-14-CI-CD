provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "BRIEF14_MAXIMEL" {
  name     = "BRIEF14_MAXIMEL"
  location = "Europe Nord"  # Modifiez la région selon vos besoins
}
