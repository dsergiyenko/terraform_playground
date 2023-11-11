terraform {
required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.53.0"
    }
  }
}

provider "openstack" {
  user_name   = "${var.user_name}" 
  password    = "${var.password}"
  tenant_name = "${var.tenant_name}"
  auth_url    = "https://auth.pscloud.io/v3/"
  region      = "kz-ala-1"
                     }
