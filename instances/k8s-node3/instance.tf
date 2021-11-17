resource "oci_core_instance" "k8s-node3" {
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
  preemptible_instance_config {
    preemption_action {
      preserve_boot_volume = false
      type                 = "TERMINATE"
    }
  }
  display_name         = var.instance_display_name
  create_vnic_details {
    assign_public_ip = true
    subnet_id        = var.subnet_id
  }
  metadata             = {
    ssh_authorized_keys = var.ssh_public_keys
    # Automate NAT instance configuration with cloud init run at launch
    user_data           = data.template_cloudinit_config.k8s-node3.rendered
  }
  preserve_boot_volume = false

  provisioner "local-exec" {
    command = "echo start"
  }

  provisioner "local-exec" {
    command = "sleep 5m"
  }

  provisioner "local-exec" {
    command = "if [ $(kubectl --kubeconfig /u01/workspace/terraform/instances/k8s-node1/scripts/kubeconfig get nodes --no-headers=true | grep -v Ready | grep none | wc -l ) -gt 0 ]; then kubectl --kubeconfig /u01/workspace/terraform/instances/k8s-node1/scripts/kubeconfig get nodes --no-headers=true | grep -v Ready | grep none | awk '{print $1}' | xargs kubectl --kubeconfig /u01/workspace/terraform/instances/k8s-node1/scripts/kubeconfig drain --force;fi"
  }

  provisioner "local-exec" {
    command = "if [ $(kubectl --kubeconfig /u01/workspace/terraform/instances/k8s-node1/scripts/kubeconfig get nodes --no-headers=true | grep -v Ready | grep none | wc -l ) -gt 0 ]; then kubectl --kubeconfig /u01/workspace/terraform/instances/k8s-node1/scripts/kubeconfig get nodes --no-headers=true | grep -v Ready | grep none | awk '{print $1}' | xargs kubectl --kubeconfig /u01/workspace/terraform/instances/k8s-node1/scripts/kubeconfig delete node;fi"
  }

  provisioner "local-exec" {
    command = "echo done"
  }

  timeouts {
    create = "60m"
  }

}

# Outputs for Kubernetes Instances
output "k8s-node3-name" {
  value = oci_core_instance.k8s-node3.display_name
}
output "k8s-node3-public-ip" {
  value = oci_core_instance.k8s-node3.public_ip
}
output "k8s-node3-ocid" {
  value = oci_core_instance.k8s-node3.id
}