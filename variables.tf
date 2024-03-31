variable "vpc_id" {
  type        = string
  description = "AWS VPC that will be peered to Mongo Atlas project"
}

variable "vpc_cidr_block" {
  type        = string
  description = "The AWS VPC CIDR block that will be added to the Mongo Atlas project's route table"
}

variable "peering_connection_name" {
  type        = string
  description = "Name to give to the AWS VPC Peering connection"
}

variable "atlas_project_name" {
  type        = string
  description = "Name of the Atlas project"
}

variable "atlas_cidr_block" {
  type        = string
  description = "CIDR block granted to the Atlas project"
}

variable "create_shared_db" {
  type        = bool
  description = "If `true`, create a shared db"
  default     = true
}

variable "region" {
  description = "region"
  type        = string
  default     = null
}

variable "env" {
  description = "environment"
  type        = string
  default     = null
}

variable "jenkins" {
  description = "Name of the jenkins VPC(s) resources: name, acct_id, cidr, region, vpc_id"
  type        = map(any)
  default     = {}
}

variable "database_users" {
  description = "Map of MongoDB Atlas database users"
  type = map(object({
    username           = string
    password           = string
    auth_database_name = string
    roles = list(object({
      database_name = string
      role_name     = string
    }))
  }))
}

variable "custom_roles" {
  type = map(object({
    role_name = string
    actions = list(object({
      action = string
      resources = object({
        collection_name = string
        database_name   = string
      })
    }))
  }))
}