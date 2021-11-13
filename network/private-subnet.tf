# Source from https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_subnet

resource "oci_core_subnet" "vcn-private-nodes-subnet" {

  # Required
  compartment_id = var.compartment_id
  vcn_id         = module.vcn.vcn_id
  cidr_block     = "10.0.10.0/24"

  # Optional
  # Caution: For the route table id, use module.vcn.nat_route_id.
  # Do not use module.vcn.nat_gateway_id, because it is the OCID for the gateway and not the route table.
  route_table_id             = module.vcn.nat_route_id
  security_list_ids          = [oci_core_security_list.private-nodes-security-list.id]
  display_name               = "private-nodes-subnet"
  prohibit_public_ip_on_vnic = true
  dns_label                  = "privatenodes"
}

# Outputs for private subnet
output "private-nodes-subnet-name" {
  value = oci_core_subnet.vcn-private-nodes-subnet.display_name
}
output "private-nodes-subnet-ocid" {
  value = oci_core_subnet.vcn-private-nodes-subnet.id
}