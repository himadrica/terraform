output "cluster_id" {
  description = "ID of the OpenShift cluster"
  value       = ibm_container_vpc_cluster.openshift.id
}

output "cluster_name" {
  description = "Name of the OpenShift cluster"
  value       = ibm_container_vpc_cluster.openshift.name
}

output "cluster_crn" {
  description = "CRN of the OpenShift cluster"
  value       = ibm_container_vpc_cluster.openshift.crn
}

output "cluster_ingress_hostname" {
  description = "Ingress hostname for the cluster"
  value       = ibm_container_vpc_cluster.openshift.ingress_hostname
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = ibm_is_vpc.openshift_vpc.id
}


output "cluster_master_url" {
  description = "Master URL for the OpenShift cluster"
  value       = ibm_container_vpc_cluster.openshift.master_url
}

output "cluster_state" {
  description = "Current state of the OpenShift cluster"
  value       = ibm_container_vpc_cluster.openshift.state
}

output "cluster_master_status" {
  description = "Status of the cluster master"
  value       = ibm_container_vpc_cluster.openshift.master_status
}

output "cluster_public_service_endpoint_url" {
  description = "Public service endpoint URL"
  value       = ibm_container_vpc_cluster.openshift.public_service_endpoint_url
}

output "cluster_private_service_endpoint_url" {
  description = "Private service endpoint URL"
  value       = ibm_container_vpc_cluster.openshift.private_service_endpoint_url
}

output "security_group_id" {
  description = "ID of the security group for the OpenShift cluster"
  value       = ibm_is_security_group.openshift_sg.id
}

output "cos_instance_crn" {
  description = "CRN of the Cloud Object Storage instance"
  value       = ibm_resource_instance.cos.crn
}

output "subnet_ids" {
  description = "Map of zone to subnet ID"
  value       = { for k, v in ibm_is_subnet.subnets : k => v.id }
}

output "public_gateway_ids" {
  description = "Map of zone to public gateway ID"
  value       = { for k, v in ibm_is_public_gateway.gateway : k => v.id }
}

output "monitoring_enabled" {
  description = "Whether monitoring and logging are enabled"
  value       = var.enable_monitoring
}

output "resource_group_id" {
  description = "ID of the resource group"
  value       = data.ibm_resource_group.group.id
}
