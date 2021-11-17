# Output the "list" of all availability domains.
output "public-master-subnet-name" {
  value = module.network.public-master-subnet-name
}
output "public-master-subnet-ocid" {
  value = module.network.public-master-subnet-ocid
}
output "public-lb-subnet-name" {
  value = module.network.public-lb-subnet-name
}
output "public-lb-subnet-ocid" {
  value = module.network.public-lb-subnet-ocid
}
output "k8s-master-name" {
  value = module.k8s-master.k8s-master-name
}
output "k8s-master-ocid" {
  value = module.k8s-master.k8s-master-ocid
}
output "k8s-master-public-ip" {
  value = module.k8s-master.k8s-master-public-ip
}
output "k8s-node1-name" {
  value = module.k8s-node1.k8s-node1-name
}
output "k8s-node1-ocid" {
  value = module.k8s-node1.k8s-node1-ocid
}
output "k8s-node1-public-ip" {
  value = module.k8s-node1.k8s-node1-public-ip
}
output "k8s-node2-name" {
  value = module.k8s-node2.k8s-node2-name
}
output "k8s-node2-ocid" {
  value = module.k8s-node2.k8s-node2-ocid
}
output "k8s-node2-public-ip" {
  value = module.k8s-node2.k8s-node2-public-ip
}
output "k8s-node3-name" {
  value = module.k8s-node3.k8s-node3-name
}
output "k8s-node3-ocid" {
  value = module.k8s-node3.k8s-node3-ocid
}
output "k8s-node3-public-ip" {
  value = module.k8s-node3.k8s-node3-public-ip
}