#ID исползуемого образа ( CentOS-7.9-x86_64-202302 ) https://dashboard.pscloud.io/dashboard/project/images
variable "image_id" {
default = "c4b81bef-07dd-489d-a8d4-36aa2a94dce4"
}

variable "user_name" {
  description = "OpenStack username"
}

variable "tenant_name" {
  description = "OpenStack tenant/project name"
}

variable "password" {
  description = "OpenStack user password"
}

variable "ssh_public_key" {
  description = "ssh key"
}
