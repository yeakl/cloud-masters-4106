resource "yandex_iam_service_account" "k8s_service_account" {
  name        = "k8s-cluster-sa"
  description = "Service account for Kubernetes cluster"
}

# Роли для K8s Service Account
resource "yandex_resourcemanager_folder_iam_member" "k8s_clusters_agent" {
  folder_id = var.folder_id
  role      = "k8s.clusters.agent"
  member    = "serviceAccount:${yandex_iam_service_account.k8s_service_account.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "vpc_public_admin" {
  folder_id = var.folder_id
  role      = "vpc.publicAdmin"
  member    = "serviceAccount:${yandex_iam_service_account.k8s_service_account.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "load_balancer_admin" {
  folder_id = var.folder_id
  role      = "load-balancer.admin"
  member    = "serviceAccount:${yandex_iam_service_account.k8s_service_account.id}"
}

# Service Account для Node Group
resource "yandex_iam_service_account" "k8s_node_service_account" {
  name        = "k8s-node-sa"
  description = "Service account for Kubernetes node group"
}

resource "yandex_resourcemanager_folder_iam_member" "k8s_node_group_images_puller" {
  folder_id = var.folder_id
  role      = "container-registry.images.puller"
  member    = "serviceAccount:${yandex_iam_service_account.k8s_node_service_account.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "k8s_node_group_images_pusher" {
  folder_id = var.folder_id
  role      = "container-registry.images.pusher"
  member    = "serviceAccount:${yandex_iam_service_account.k8s_node_service_account.id}"
}

resource "yandex_kubernetes_cluster" "k8s_cluster" {
  name                     = var.cluster
  network_id               = yandex_vpc_network.k8s_network.id
  folder_id                = var.folder_id
  service_account_id       = yandex_iam_service_account.k8s_service_account.id
  node_service_account_id  = yandex_iam_service_account.k8s_node_service_account.id
  node_ipv4_cidr_mask_size = 24

  master {
    public_ip = true

    zonal {
      zone      = var.zone
      subnet_id = yandex_vpc_subnet.k8s_subnet.id
    }
  }
}

resource "yandex_kubernetes_node_group" "k8s_node_group" {
  cluster_id = yandex_kubernetes_cluster.k8s_cluster.id

  scale_policy {
    fixed_scale {
      size = 1
    }
  }

  allocation_policy {
    location {
      zone = var.zone
    }
  }

  instance_template {
    platform_id = "standard-v1"

    resources {
      cores         = 2
      memory        = 4
      core_fraction = 20
    }

    scheduling_policy {
      preemptible = true
    }

    network_interface {
      nat        = true
      ipv4       = true
      subnet_ids = [yandex_vpc_subnet.k8s_subnet.id]
    }

    metadata = {
      ssh-keys = "ubuntu:${file(var.ssh_key_path)}"
    }
  }

  maintenance_policy {
    auto_upgrade = true
    auto_repair  = true
  }
}
