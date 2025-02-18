terraform {
  required_providers {
    libvirt = {
        source = "dmacvicar/libvirt"
    }
    ansible = {
      #version = "~> 1.3.0"
      source  = "ansible/ansible"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}