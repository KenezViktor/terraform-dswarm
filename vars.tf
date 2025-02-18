# Disk images
variable "image" {
  #source = "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2"
  #default = "/var/lib/libvirt/images/debian-12-genericcloud-amd64.qcow2"
  default = "/var/lib/libvirt/images/base-debian"
  description = "Source of the Debian image"
}

# VM related vars
variable "number_of_workers" {
  default = 6
  description = "The number of how many worker servers do we need"
}

variable "number_of_managers" {
  default = 3
  description = "The number of how many manager servers do we need"
}

variable "number_of_storages" {
  default = 1
  description = "The number of how many manager servers do we need"
}

variable "domain_name" {
  default = ".office.lab"
  description = "Domain name for the VMs"
}

variable "worker_subdomain" {
  default = "worker-"
  description = "Generic subdomain for worker VMs"
}

variable "manager_subdomain" {
  default = "manager-"
  description = "Generic subdomain for worker VMs"
}

variable "storage_subdomain" {
  default = "storage-"
  description = "Generic subdomain for worker VMs"
}


# Network related vars
variable "swarm-network" {
  type = object({
    ipv4 = string
    gateway = string
    network = string
    netmask = string
    dns = string
  })
  default = {
    ipv4 = "192.168.150."
    gateway = "192.168.150.1"
    network = "192.168.150.0"
    netmask = "/24"
    dns = "192.168.150.1"
  }
  description = "Basic network settings for Sandbox VMs"
}