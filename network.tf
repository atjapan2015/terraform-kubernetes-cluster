# Resources
module "network" {
  source  = "./network"

  # general oci parameters
  compartment_id = var.compartment_id
  label_prefix   = var.label_prefix
  freeform_tags  = var.freeform_tags

  # vcn parameters
  create_drg               = var.create_drg               # boolean: true or false
  create_internet_gateway  = var.create_internet_gateway  # boolean: true or false
  lockdown_default_seclist = var.lockdown_default_seclist # boolean: true or false
  create_nat_gateway       = var.create_nat_gateway       # boolean: true or false
  create_service_gateway   = var.create_service_gateway   # boolean: true or false
  enable_ipv6              = var.enable_ipv6
  vcn_cidrs                = var.vcn_cidrs # List of IPv4 CIDRs
  vcn_dns_label            = var.vcn_dns_label
  vcn_name                 = var.vcn_name

  # gateways parameters
  drg_display_name              = var.drg_display_name
  internet_gateway_display_name = var.internet_gateway_display_name
  nat_gateway_display_name      = var.nat_gateway_display_name
  service_gateway_display_name  = var.service_gateway_display_name
}