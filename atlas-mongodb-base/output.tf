output "container_id" {
  value       = mongodbatlas_network_container.this.id
  description = "ID of the Mongo Atlas Container"
}

output "project_id" {
  value       = mongodbatlas_project.this.id
  description = "ID of the Mongo Atlas Project"
}

output "peer_id" {
  value       = mongodbatlas_network_peering.this
  description = "ID of the Mongo peer for this env"
}

output "account_id" {
  value = data.aws_caller_identity.current
}