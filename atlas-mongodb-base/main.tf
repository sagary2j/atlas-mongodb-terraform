data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.4"
    }
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 1.9"
    }
  }
}

locals {
  atlas_region_names = {
    "us-east-1" = "US_EAST_1"
    "us-west-2" = "US_WEST_2"
  }
  region_name = local.atlas_region_names[data.aws_region.current.name]
}

resource "mongodbatlas_project" "this" {
  name   = var.atlas_project_name
  org_id = var.atlas_organization_id
}

resource "mongodbatlas_network_container" "this" {
  atlas_cidr_block = var.atlas_cidr_block
  project_id       = mongodbatlas_project.this.id
  provider_name    = "AWS"
  region_name      = local.region_name
}

resource "mongodbatlas_network_peering" "this" {
  container_id           = mongodbatlas_network_container.this.id
  project_id             = mongodbatlas_project.this.id
  provider_name          = "AWS"
  accepter_region_name   = data.aws_region.current.id
  vpc_id                 = var.vpc_id
  aws_account_id         = data.aws_caller_identity.current.account_id
  route_table_cidr_block = var.vpc_cidr_block
}

resource "aws_vpc_peering_connection_accepter" "this" {
  vpc_peering_connection_id = mongodbatlas_network_peering.this.connection_id
  auto_accept               = true
  tags = {
    Name = var.peering_connection_name
  }
}

resource "mongodbatlas_project_ip_access_list" "this" {
  project_id = mongodbatlas_network_peering.this.project_id
  cidr_block = var.vpc_cidr_block
  comment    = "Grant AWS ${var.vpc_cidr_block} environment access to Atlas resources"
}

resource "aws_route" "this" {
  for_each                  = toset(var.private_route_table_ids)
  route_table_id            = each.value
  destination_cidr_block    = mongodbatlas_network_container.this.atlas_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.this.vpc_peering_connection_id
}
