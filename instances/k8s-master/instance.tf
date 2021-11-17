resource "oci_core_instance" "k8s-master" {
  # Required
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_id
  shape               = var.shape
  source_details {
    source_id   = var.source_ocid
    source_type = "image"
  }

  # Optional
  # Some actions are not allowed for preemptible instances, such as starting, stopping and rebooting the instance.
  # https://docs.oracle.com/en-us/iaas/Content/Compute/Concepts/preemptible.htm#support
#  preemptible_instance_config {
#    preemption_action {
#      preserve_boot_volume = false
#      type                 = "TERMINATE"
#    }
#  }
  display_name         = var.instance_display_name
  create_vnic_details {
    assign_public_ip = true
    subnet_id        = var.subnet_id
  }
  metadata             = {
    ssh_authorized_keys = var.ssh_public_keys
    # Automate NAT instance configuration with cloud init run at launch
    user_data           = data.template_cloudinit_config.k8s-master.rendered
  }
  preserve_boot_volume = false

  provisioner "local-exec" {
    command = "echo start"
  }

  provisioner "local-exec" {
    command = "sleep 10m"
  }

  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null opc@${self.public_ip}:/home/opc/join.sh /u01/workspace/terraform/instances/k8s-node1/scripts/"
  }

  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null opc@${self.public_ip}:/home/opc/.kube/config /u01/workspace/terraform/instances/k8s-node1/scripts/kubeconfig"
  }

  provisioner "local-exec" {
    command = "echo done"
  }

  timeouts {
    create = "60m"
  }
}

#resource "oci_core_instance" "k8s-node1" {
#    # Required
#    availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
#    compartment_id = "ocid1.compartment.oc1..aaaaaaaahr7aicqtodxmcfor6pbqn3hvsngpftozyxzqw36gj4kh3w3kkj4q"
#    shape = "VM.Standard2.2"
#    source_details {
#        source_id = "ocid1.image.oc1.ap-chuncheon-1.aaaaaaaazqpx7inb57iim2uru63u3q2jy3nqr5u3tnw6e7q5oelk6jeptl4q"
#        source_type = "image"
#    }
#
#    # Optional
#    preemptible_instance_config {
#        preemption_action {
#            preserve_boot_volume = false
#            type = "TERMINATE"
#        }
#    }
#    display_name = "k8s-node1"
#    create_vnic_details {
#        assign_public_ip = true
#        subnet_id = oci_core_subnet.vcn-private-nodes-subnet.id
#    }
#    metadata = {
#        ssh_authorized_keys = var.ssh_public_keys
#    }
#    preserve_boot_volume = false
#}

# Outputs for Kubernetes Instances
output "k8s-master-name" {
  value = oci_core_instance.k8s-master.display_name
}
output "k8s-master-public-ip" {
  value = oci_core_instance.k8s-master.public_ip
}
output "k8s-master-ocid" {
  value = oci_core_instance.k8s-master.id
}

#output "k8s-node1-name" {
#    value = oci_core_instance.k8s-node1.display_name
#}
#output "k8s-node1-ip" {
#    value = oci_core_instance.k8s-node1.public_ip
#}
#output "k8s-node1-ocid" {
#    value = oci_core_instance.k8s-node1.id
#}