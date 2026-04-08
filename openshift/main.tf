# -------------------------------------------------------------------
# Data source: look up the existing resource group by name
# -------------------------------------------------------------------
data "ibm_resource_group" "group" {
  name = var.resource_group_name
}

# -------------------------------------------------------------------
# VPC + Subnets
# -------------------------------------------------------------------
resource "ibm_is_vpc" "openshift_vpc" {
  name           = var.vpc_name
  resource_group = data.ibm_resource_group.group.id
}

resource "ibm_is_public_gateway" "gateway" {
  for_each = toset(var.worker_zones)

  name           = "${var.vpc_name}-gw-${each.key}"
  vpc            = ibm_is_vpc.openshift_vpc.id
  zone           = each.key
  resource_group = data.ibm_resource_group.group.id
}

resource "ibm_is_subnet" "subnets" {
  for_each = toset(var.worker_zones)

  name                     = "${var.vpc_name}-subnet-${each.key}"
  vpc                      = ibm_is_vpc.openshift_vpc.id
  zone                     = each.key
  total_ipv4_address_count = 256
  public_gateway           = ibm_is_public_gateway.gateway[each.key].id
  resource_group           = data.ibm_resource_group.group.id
}

# -------------------------------------------------------------------
# Cloud Object Storage (required for VPC-based OpenShift clusters)
# -------------------------------------------------------------------
resource "ibm_resource_instance" "cos" {
  name              = var.cos_instance_name
  resource_group_id = data.ibm_resource_group.group.id
  service           = "cloud-object-storage"
  plan              = "standard"
  location          = "global"
}

# -------------------------------------------------------------------
# OpenShift Cluster on VPC
# -------------------------------------------------------------------
resource "ibm_container_vpc_cluster" "openshift" {
  name              = var.cluster_name
  vpc_id            = ibm_is_vpc.openshift_vpc.id
  kube_version      = var.ocp_version
  flavor            = var.worker_pool_flavor
  worker_count      = var.worker_count
  resource_group_id = data.ibm_resource_group.group.id
  cos_instance_crn  = ibm_resource_instance.cos.id
  entitlement       = var.ocp_entitlement

  dynamic "zones" {
    for_each = ibm_is_subnet.subnets
    content {
      name      = zones.value.zone
      subnet_id = zones.value.id
    }
  }

  timeouts {
    create = "90m"
    delete = "45m"
  }
}
