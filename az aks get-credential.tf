resource "null_resource" "configure_kubectl" {
  provisioner "local-exec" {
    command = "az aks get-credentials --resource-group ${azurerm_resource_group.example.name} --name ${azurerm_kubernetes_cluster.example.name}"
  }
}

# Exécutez la commande `kubectl get nodes` pour vérifier la connexion.
resource "null_resource" "verify_kubectl" {
  depends_on = [null_resource.configure_kubectl]

  provisioner "local-exec" {
    command = "kubectl get nodes"
  }
}
