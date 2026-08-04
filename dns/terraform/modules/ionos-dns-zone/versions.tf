terraform {
  required_version = ">= 1.3.0"
  required_providers {
    ionoscloud = {
      source  = "ionos-cloud/ionoscloud"
      version = "~> 6.0"
    }
  }
}
