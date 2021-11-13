# Source from https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_security_list

resource "oci_core_security_list" "public-master-security-list" {

  # Required
  compartment_id = var.compartment_id
  vcn_id         = module.vcn.vcn_id

  # Optional
  display_name = "security-list-for-public-master-subnet"

  ingress_security_rules {
    description = "External SSH traffic to control plane"
    stateless   = false
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml TCP is 6
    protocol    = "6"
    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    description = "External access to control plane NodePort"
    stateless   = false
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml TCP is 6
    protocol    = "6"

    tcp_options {
      min = 30000
      max = 32767
    }
  }

  ingress_security_rules {
    description = "External access to Kubernetes API endpoint"
    stateless   = false
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml TCP is 6
    protocol    = "6"

    tcp_options {
      min = 6443
      max = 6443
    }
  }

  ingress_security_rules {
    description = "Kubernetes worker to Kubernetes API endpoint communication"
    stateless   = false
    source      = "10.0.10.0/24"
    source_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml TCP is 6
    protocol    = "6"

    tcp_options {
      min = 6443
      max = 6443
    }
  }

  ingress_security_rules {
    description = "Kubernetes worker to control plane communication"
    stateless   = false
    source      = "10.0.10.0/24"
    source_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml TCP is 6
    protocol    = "6"

    tcp_options {
      min = 12250
      max = 12250
    }
  }

  ingress_security_rules {
    description = "Path discovery"
    stateless   = false
    source      = "10.0.10.0/24"
    source_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml ICMP is 1
    protocol    = "1"

    # For ICMP type and code see: https://www.iana.org/assignments/icmp-parameters/icmp-parameters.xhtml
    icmp_options {
      type = 3
      code = 4
    }
  }

  egress_security_rules {
    description      = "Master node access to Internet"
    stateless        = false
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }

  egress_security_rules {
    description      = "Allow Kubernetes Control Plane to communicate with OKE"
    stateless        = false
    destination      = "all-yny-services-in-oracle-services-network"
    destination_type = "SERVICE_CIDR_BLOCK"
    protocol         = "6"

    tcp_options {
      min = 443
      max = 443
    }
  }

  egress_security_rules {
    description      = "All traffic to worker nodes"
    stateless        = false
    destination      = "10.0.10.0/24"
    destination_type = "CIDR_BLOCK"
    protocol         = "6"
  }

  egress_security_rules {
    description      = "Path discovery"
    stateless        = false
    destination      = "10.0.10.0/24"
    destination_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml ICMP is 1
    protocol         = "1"

    # For ICMP type and code see: https://www.iana.org/assignments/icmp-parameters/icmp-parameters.xhtml
    icmp_options {
      type = 3
      code = 4
    }
  }
}

resource "oci_core_security_list" "public-lb-security-list" {

  # Required
  compartment_id = var.compartment_id
  vcn_id         = module.vcn.vcn_id

  # Optional
  display_name = "security-list-for-public-lb-subnet"

  ingress_security_rules {
    description = "External http traffic to LoadBalancer"
    stateless   = false
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml ICMP is 1
    protocol    = "6"

    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    description = "External https traffic to LoadBalancer"
    stateless   = false
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml ICMP is 1
    protocol    = "6"

    tcp_options {
      min = 443
      max = 443
    }
  }

  egress_security_rules {
    description      = "LoadBalancer access to Internet"
    stateless        = false
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }
}

# Outputs for public security list
output "public-master-security-list-name" {
  value = oci_core_security_list.public-master-security-list.display_name
}
output "public-master-security-list-ocid" {
  value = oci_core_security_list.public-master-security-list.id
}

output "public-lb-security-list-name" {
  value = oci_core_security_list.public-lb-security-list.display_name
}
output "public-lb-security-list-ocid" {
  value = oci_core_security_list.public-lb-security-list.id
}