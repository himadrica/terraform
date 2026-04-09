# -------------------------------------------------------------------
# Monitoring and Logging (Optional)
# -------------------------------------------------------------------
resource "ibm_container_addons" "openshift_logging" {
  count = var.enable_monitoring && var.logdna_instance_id != "" ? 1 : 0

  cluster           = ibm_container_vpc_cluster.openshift.id
  resource_group_id = data.ibm_resource_group.group.id

  addons {
    name    = "logdna"
    version = null
  }
}

resource "ibm_container_addons" "openshift_monitoring" {
  count = var.enable_monitoring && var.sysdig_instance_id != "" ? 1 : 0

  cluster           = ibm_container_vpc_cluster.openshift.id
  resource_group_id = data.ibm_resource_group.group.id

  addons {
    name    = "sysdig"
    version = null
  }
}

# -------------------------------------------------------------------
# Local variables for consistent tagging
# -------------------------------------------------------------------
locals {
  common_tags = concat(
    [
      "environment:${var.environment}",
      "project:openshift",
      "managed-by:terraform",
      "cluster:${var.cluster_name}"
    ],
    var.tags
  )
}

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
  tags           = local.common_tags
}

resource "ibm_is_public_gateway" "gateway" {
  for_each = toset(var.worker_zones)

  name           = "${var.vpc_name}-gw-${each.key}"
  vpc            = ibm_is_vpc.openshift_vpc.id
  zone           = each.key
  resource_group = data.ibm_resource_group.group.id
  tags           = local.common_tags
}

resource "ibm_is_subnet" "subnets" {
  for_each = toset(var.worker_zones)

  name                     = "${var.vpc_name}-subnet-${each.key}"
  vpc                      = ibm_is_vpc.openshift_vpc.id
  zone                     = each.key
  total_ipv4_address_count = 256
  public_gateway           = ibm_is_public_gateway.gateway[each.key].id
  resource_group           = data.ibm_resource_group.group.id
  tags                     = local.common_tags
}

# -------------------------------------------------------------------
# Security Group for OpenShift Cluster
# -------------------------------------------------------------------
resource "ibm_is_security_group" "openshift_sg" {
  name           = "${var.cluster_name}-sg"
  vpc            = ibm_is_vpc.openshift_vpc.id
  resource_group = data.ibm_resource_group.group.id
  tags           = local.common_tags
}

# Allow inbound HTTPS traffic
resource "ibm_is_security_group_rule" "allow_https_inbound" {
  group     = ibm_is_security_group.openshift_sg.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  protocol  = "tcp"
  port_min  = 443
  port_max  = 443
}

# Allow inbound HTTP traffic (for redirects)
resource "ibm_is_security_group_rule" "allow_http_inbound" {
  group     = ibm_is_security_group.openshift_sg.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  protocol  = "tcp"
  port_min  = 80
  port_max  = 80
}

# Allow all outbound traffic
resource "ibm_is_security_group_rule" "allow_all_outbound" {
  group     = ibm_is_security_group.openshift_sg.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
}

# Allow internal cluster communication
resource "ibm_is_security_group_rule" "allow_internal" {
  group     = ibm_is_security_group.openshift_sg.id
  direction = "inbound"
  remote    = ibm_is_security_group.openshift_sg.id
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
  tags              = local.common_tags
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
  cos_instance_crn  = ibm_resource_instance.cos.crn
  entitlement       = var.ocp_entitlement
  tags              = local.common_tags

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