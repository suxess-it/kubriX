terraform {
  required_providers {
    metal = {
      source = "metal-stack-cloud/metal"
    }
  }
}

provider "metal" {}

variable "cluster_name" {
  type    = string
  default = "sx-cluster"

  validation {
    condition     = length(var.cluster_name) >= 2 && length(var.cluster_name) <= 11
    error_message = "cluster_name must be between 2 and 11 characters for metalstack.cloud."
  }
}

variable "kubernetes_version" {
  type    = string
  default = "1.33.11"
}
