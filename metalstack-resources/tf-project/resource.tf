resource "metal_cluster" "sx-cluster" {
  name       = "sx-cluster"
  kubernetes = "1.28.10"
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
