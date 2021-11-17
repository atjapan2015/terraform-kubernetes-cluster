data "template_file" "setup-preflight" {
  template = file("${path.module}/scripts/setup.preflight.sh")

  vars = {

  }
}

data "template_file" "setup-template" {
  template = file("${path.module}/scripts/setup.template.sh")

  vars = {

  }
}

data "template_file" "kubeconfig" {
  template = file("${path.module}/scripts/kubeconfig")

  vars = {

  }
}

data "template_file" "join" {
  template = file("${path.module}/scripts/join.sh")

  vars = {

  }
}

data "template_file" "k8s_node1_cloud_init_file" {
  template = file("${path.module}/cloud_init/bootstrap.template.yaml")

  vars = {
    setup_preflight_sh_content = base64gzip(data.template_file.setup-preflight.rendered)
    setup_template_sh_content  = base64gzip(data.template_file.setup-template.rendered)
    kubeconfig_content  = base64gzip(data.template_file.kubeconfig.rendered)
    join_sh_content  = base64gzip(data.template_file.join.rendered)
  }
}

data "template_cloudinit_config" "k8s-node1" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "bootstrap.yaml"
    content_type = "text/cloud-config"
    content      = data.template_file.k8s_node1_cloud_init_file.rendered
  }
}
