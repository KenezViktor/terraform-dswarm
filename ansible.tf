resource "ansible_group" "worker" {
  name = "worker-servers"
  variables = {
    ansible_user = "root"
  }
}

resource "ansible_group" "manager" {
  name = "manager-servers"
  variables = {
    ansible_user = "root"
  }
}

resource "ansible_host" "worker" {
  count = var.number_of_workers
  name = join("", [var.worker_subdomain, count.index, var.domain_name])
  groups = [ ansible_group.worker.name ]
}

resource "ansible_host" "manager" {
  count = var.number_of_managers
  name = join("", [var.manager_subdomain, count.index, var.domain_name])
  groups = [ ansible_group.worker.name ]
}