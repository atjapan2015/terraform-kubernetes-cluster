# Source from https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_subnet

resource "oci_core_subnet" "vcn-public-master-subnet" {

  # Required
  compartment_id = var.compartment_id
  vcn_id         = module.vcn.vcn_id
  cidr_block     = "10.0.0.0/24"

  # Optional
  route_table_id    = module.vcn.ig_route_id
  security_list_ids = [oci_core_security_list.public-master-security-list.id]
  display_name      = "public-master-subnet"
  dns_label         = "publicmaster"
}

resource "oci_core_subnet" "vcn-public-lb-subnet" {

  # Required
  compartment_id = var.compartment_id
  vcn_id         = module.vcn.vcn_id
  cidr_block     = "10.0.20.0/24"

  # Optional
  route_table_id    = module.vcn.ig_route_id
  security_list_ids = [oci_core_security_list.public-lb-security-list.id]
  display_name      = "public-lb-subnet"
  dns_label         = "publiclb"
}

# Outputs for public subnet
output "public-master-subnet-name" {
  value = oci_core_subnet.vcn-public-master-subnet.display_name
}
output "public-master-subnet-ocid" {
  value = oci_core_subnet.vcn-public-master-subnet.id
}

output "public-lb-subnet-name" {
  value = oci_core_subnet.vcn-public-lb-subnet.display_name
}
output "public-lb-subnet-ocid" {
  value = oci_core_subnet.vcn-public-lb-subnet.id
}