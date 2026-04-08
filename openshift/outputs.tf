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
