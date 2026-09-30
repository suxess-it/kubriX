resource "metal_cluster" "sx-cluster" {
  name       = var.cluster_name
  kubernetes = var.kubernetes_version
  partition  = "eqx-mu4"
  workers = [
    {
      name         = "default"
      machine_type = "n1-medium-x86"
      min_size     = 1
      max_size     = 3
    }
  ]
  maintenance = {
    time_window = {
      begin = {
        hour   = 18
        minute = 30
      }
      duration = 2
    }
  }
}

data "metal_kubeconfig" "sx-cluster" {
  id         = metal_cluster.sx-cluster.id
  expiration = "12h"
}

output "kubeconfig" {
  value     = data.metal_kubeconfig.sx-cluster.raw
  sensitive = true
}
