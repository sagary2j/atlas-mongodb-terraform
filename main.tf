data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  env = "<%= Terraspace.env %>"
  atlas_region_names = {
    "us-east-1" = "US_EAST_1"
    "us-west-2" = "US_WEST_2"
  }
  region_name = local.atlas_region_names[data.aws_region.current.name]
  uri_path    = split("//", mongodbatlas_advanced_cluster.shared[0].connection_strings[0].standard_srv)
}


data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_route_tables" "private" {
  vpc_id = data.aws_vpc.selected.id
}

data "aws_ssm_parameter" "private_key" {
  name            = "/atlas/private-key"
  with_decryption = true
}

data "aws_ssm_parameter" "public_key" {
  name            = "/atlas/public-key"
  with_decryption = true
}

data "aws_ssm_parameter" "atlas_organization_id" {
  name            = "/atlas/org-id"
  with_decryption = true
}

data "aws_secretsmanager_secret_version" "creds" {
  secret_id = "atlas/${data.aws_region.current.name}/atlas-users"
}

provider "mongodbatlas" {
  public_key  = data.aws_ssm_parameter.public_key.value
  private_key = data.aws_ssm_parameter.private_key.value
}

module "atlas_project" {
  source = "./atlas-mongodb-base"

  atlas_cidr_block        = var.atlas_cidr_block
  atlas_organization_id   = data.aws_ssm_parameter.atlas_organization_id.value
  atlas_project_name      = var.atlas_project_name
  peering_connection_name = var.peering_connection_name
  private_route_table_ids = data.aws_route_tables.private.ids
  vpc_cidr_block          = var.vpc_cidr_block
  vpc_id                  = var.vpc_id
}

resource "mongodbatlas_advanced_cluster" "shared" {
  count                  = var.create_shared_db ? 1 : 0
  cluster_type           = "REPLICASET"
  name                   = "${var.atlas_project_name}-shared"
  project_id             = module.atlas_project.project_id
  mongo_db_major_version = "5.0"
  replication_specs {
    region_configs {
      electable_specs {
        instance_size = "M10"
        node_count    = 3
      }
      priority      = 7
      provider_name = "AWS"
      region_name   = local.region_name
    }
  }
}

resource "mongodbatlas_custom_db_role" "roles" {
  for_each   = var.custom_roles
  project_id = module.atlas_project.project_id
  role_name  = each.value.role_name

  dynamic "actions" {
    for_each = each.value.actions
    content {
      action = actions.value.action
      resources {
        collection_name = actions.value.resources.collection_name
        database_name   = actions.value.resources.database_name
      }
    }
  }
}

resource "mongodbatlas_database_user" "database_users" {
  for_each           = var.database_users
  username           = each.value.username
  password           = jsondecode(data.aws_secretsmanager_secret_version.creds.secret_string)[each.value.username]
  auth_database_name = "admin"
  project_id         = module.atlas_project.project_id

  dynamic "roles" {
    for_each = each.value.roles
    content {
      database_name = roles.value.database_name
      role_name     = roles.value.role_name
    }
  }
  depends_on = [mongodbatlas_custom_db_role.roles]
}
