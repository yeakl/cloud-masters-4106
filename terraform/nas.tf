resource "yandex_compute_image" "ansible_vm_image" {
  source_family = "ubuntu-2204-lts"
}

resource "yandex_compute_instance" "nas_ansible_instance" {
  name = "nas-ansible"
  platform_id = "standard-v1"
  zone        = var.zone

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = yandex_compute_image.ansible_vm_image.id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.k8s_subnet.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_key_path)}"
  }

  scheduling_policy {
    preemptible = true
  }

  maintenance_policy = "restart"
}