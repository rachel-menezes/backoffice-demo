variable "region" {
  default = "eu-west-1"
}

variable "name" {
  default = "backoffice-demo"
}

variable "environment" {
  default = "backoffice-demo-env"
}

variable "database_name" {}
variable "database_password" {}
variable "database_url" {}
variable "database_user" {}

variable "public_subnets" {
  default = ["172.0.16.0/20", "172.0.48.0/20", "172.0.80.0/20"]
}