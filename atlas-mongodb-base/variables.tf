variable "vpc_id" {
  type        = string
  description = "ID of VPC to peer to Atlas project"
}

variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block of AWS VPC"
}

variable "atlas_project_name" {
  type        = string
  description = "Name of the Atlas project"
}

variable "atlas_organization_id" {
  type        = string
  description = "Organization ID the Atlas project resides in"
}

variable "peering_connection_name" {
  type        = string
  description = "Name to give to the AWS VPC Peering connection"
}



variable "atlas_cidr_block" {
  type        = string
  description = "CIDR block granted to the Atlas project"
}

variable "private_route_table_ids" {
  type        = list(string)
  description = "A route to Mongo Atlas will be added each of the route tables specified"
}