resource "ansible_group" "worker" {
  name = "worker-servers"
  variables = {
    ansible_user = "root"
    ansible_ssh_private_key_file = "~/.ssh/packer_key"
  }
}

resource "ansible_group" "manager" {
  name = "manager-servers"
  variables = {
    ansible_user = "root"
    ansible_ssh_private_key_file = "~/.ssh/packer_key"
  }
}

resource "ansible_group" "storage" {
  name = "storage-servers"
  variables = {
    ansible_user = "root"
    ansible_ssh_private_key_file = "~/.ssh/packer_key"
  }
}

resource "ansible_host" "worker" {
  count = var.number_of_workers
  name = join("", [var.worker_subdomain, count.index + 1, var.domain_name])
  groups = [ ansible_group.worker.name ]
}

resource "ansible_host" "manager" {
  count = var.number_of_managers
  name = join("", [var.manager_subdomain, count.index + 1, var.domain_name])
  groups = [ ansible_group.manager.name ]
}

resource "ansible_host" "storage" {
  count = var.number_of_storages
  name = join("", [var.storage_subdomain, count.index + 1, var.domain_name])
  groups = [ ansible_group.storage.name ]
}