variable "ibmcloud_api_key" {
  description = "IBM Cloud API key"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "IBM Cloud region for the OpenShift cluster"
  type        = string
  default     = "us-south"
}

variable "resource_group_name" {
  description = "Name of the existing IBM Cloud resource group"
  type        = string
}

variable "cluster_name" {
  description = "Name of the OpenShift cluster"
  type        = string
  default     = "my-openshift-cluster"
}

variable "ocp_version" {
  description = "OpenShift version (e.g. 4.15_openshift)"
  type        = string
  default     = "4.15_openshift"
}

variable "worker_pool_flavor" {
  description = "Machine flavor for worker nodes"
  type        = string
  default     = "bx2.4x16"
}

variable "worker_count" {
  description = "Number of worker nodes per zone"
  type        = number
  default     = 2
}

variable "cos_instance_name" {
  description = "Name for the Cloud Object Storage instance (required for VPC OpenShift)"
  type        = string
  default     = "openshift-cos"
}

variable "vpc_name" {
  description = "Name of the VPC to create"
  type        = string
  default     = "openshift-vpc"
}

variable "worker_zones" {
  description = "List of zones for worker nodes"
  type        = list(string)
  default     = ["us-south-1", "us-south-2", "us-south-3"]
}

variable "ocp_entitlement" {
  description = "OpenShift entitlement (set to 'cloud_pak' if using a Cloud Pak entitlement)"
  type        = string
  default     = "cloud_pak"
}
