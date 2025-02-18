resource "libvirt_volume" "manager-qcow2" {
  count = var.number_of_managers
  name = "debian-12-manager-${count.index}.qcow2"
  pool = "default"
  source = var.image
  format = "qcow2"
}
resource "libvirt_domain" "manager" {
  count = var.number_of_managers
  name = join("", [var.manager_subdomain, count.index, var.domain_name])
  memory = 2048
  vcpu = 2

  network_interface {
    network_id = libvirt_network.manager.id
    hostname = join("", [var.manager_subdomain, count.index, var.domain_name])
    addresses = [ join("", [var.manager-network.ipv4, (count.index + 100)]) ]
  }

  disk {
    volume_id = "${libvirt_volume.manager-qcow2[count.index].id}"
  }

  console {
    type = "pty"
    target_type = "serial"
    target_port = 0
  }

  graphics {
    type = "spice"
    listen_address = "address"
    autoport = true
  }

  depends_on = [ libvirt_network.manager ]
}

# wait until VMs become ready
resource "terraform_data" "manager-up" {
  count = var.number_of_managers

  # deletes old hostkey
  provisioner "local-exec" {
    command = "ssh-keygen -f ~/.ssh/known_hosts -R ${join("", [var.manager_subdomain, count.index, var.domain_name])}"
  }

  # waits util ssh becomes ready
  provisioner "local-exec" {
    command = "until nc -zv ${join("", [var.manager_subdomain, count.index, var.domain_name])} 22; do sleep 15; done"
  }

  # adds new ssh hostkeys
  provisioner "local-exec" {
    command = "ssh-keyscan -t rsa -H ${join("", [var.manager_subdomain, count.index, var.domain_name])} >> ~/.ssh/known_hosts"
  }

  depends_on = [ libvirt_domain.manager ]
}
