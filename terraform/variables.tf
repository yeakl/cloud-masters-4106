variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "folder_id" {
  description = "Yandex Cloud Folder ID"
  type        = string
}

variable "zone" {
  description = "Availability zone"
  type        = string
  default     = "ru-central1-a"
}

variable "cluster" {
    description = "Cluster name"
    type = string
}

variable "ssh_key_path" {
    description = "SSH key path"
    type = string
}

variable "project_name" {
    description = "Project name"
    type = string  
}

variable "environment" {
  description = "Environment"
  type = string
  default = "dev"
}