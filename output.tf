output "container_id" {
  value       = module.atlas_project.container_id
  description = "ID of the Mongo Atlas Container"
}

output "project_id" {
  value       = module.atlas_project.project_id
  description = "ID of the Mongo Atlas Project"
}

output "peer_id" {
  value       = module.atlas_project.peer_id
  description = "ID of the Mongo peer for this env"
}

output "standard_srv" {
  value = mongodbatlas_advanced_cluster.shared[0].connection_strings[0].standard_srv
}