# Kubernetes outputs
output "kubernetes_cluster_id" {
  description = "ID of the Kubernetes cluster"
  value       = yandex_kubernetes_cluster.k8s_cluster.id
}

output "kubernetes_cluster_external_endpoint" {
  description = "External endpoint of the Kubernetes cluster"
  value       = yandex_kubernetes_cluster.k8s_cluster.master[0].external_v4_endpoint
}

output "kubernetes_cluster_internal_endpoint" {
  description = "Internal endpoint of the Kubernetes cluster"
  value       = yandex_kubernetes_cluster.k8s_cluster.master[0].internal_v4_endpoint
}

output "ansible_vm_external_ip" {
  description = "External IP of the Ansible VM"
  value       = yandex_compute_instance.nas_ansible_instance.network_interface.0.nat_ip_address
}

output "ansible_vm_internal_ip" {
  description = "Internal IP of the Ansible VM"
  value       = yandex_compute_instance.nas_ansible_instance.network_interface.0.ip_address
}

output "ingress_ip" {
  description = "Статический IP для Ingress NGINX"
  value       = yandex_vpc_address.ingress_lb_address.external_ipv4_address[0].address
}