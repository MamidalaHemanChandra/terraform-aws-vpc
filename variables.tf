variable "vpc_cidr_block" {
  type = string
}

variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_tags" {
  type = map
  default = {}
}

variable "igw_tags" {
  type = map
  default = {}
}

variable "public_subnet_cidr_block" {
  type = list
}

variable "public_tags" {
  type = map
  default = {}
}

variable "private_subnet_cidr_block" {
  type = list
}

variable "private_tags" {
  type = map
  default = {}
}

variable "database_subnet_cidr_block" {
  type = list
}

variable "database_tags" {
  type = map
  default = {}
}

variable "public_route_table_tags" {
  type = map
  default = {}
}

variable "private_route_table_tags" {
  type = map
  default = {}
}

variable "database_route_table_tags" {
  type = map
  default = {}
}

variable "eip_tags" {
  type = map
  default = {}
}

variable "nat_tags" {
  type = map
  default = {}
}

variable "is_perring_requried" {
  type = bool
}