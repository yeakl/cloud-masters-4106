terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  zone = var.zone
}

resource "yandex_vpc_network" "k8s_network" {
  name        = "k8s-network"
  description = "Network for Kubernetes cluster"
}

resource "yandex_vpc_subnet" "k8s_subnet" {
  name           = "k8s-subnet"
  zone           = var.zone
  network_id     = yandex_vpc_network.k8s_network.id
  v4_cidr_blocks = ["10.1.0.0/24"]
  description    = "Subnet for Kubernetes cluster"
}

resource "yandex_vpc_address" "ingress_lb_address" {
  name = "ingress-ip"

  external_ipv4_address {
    zone_id = var.zone
  }
}

resource "yandex_container_registry" "container_registry" {
  name      = "k8s-containter-registry"
  folder_id = var.folder_id
  labels = {
    environment = var.environment
    project     = var.project_name
  }
}