resource "libvirt_volume" "storage-qcow2" {
  count = var.number_of_storages
  name = "debian-12-storage-${count.index + 1}.qcow2"
  pool = "default"
  source = var.image
  format = "qcow2"
}

resource "libvirt_volume" "nfs-storage" {
  count = var.number_of_storages
  name = "nfs-storage-${count.index + 1}.qcow2"
  pool = "default"
  source = "/var/lib/libvirt/images/empty.qcow2"
  format = "qcow2"
}

resource "libvirt_domain" "storage" {
  count = var.number_of_storages
  name = join("", [var.storage_subdomain, count.index + 1, var.domain_name])
  memory = 2048
  vcpu = 2

  cpu {
    mode = "host-passthrough"
  }

  network_interface {
    network_id = libvirt_network.swarm.id
    hostname = join("", [var.storage_subdomain, count.index + 1, var.domain_name])
    addresses = [ join("", [var.swarm-network.ipv4, (count.index + 51)]) ]
  }

  disk {
    volume_id = "${libvirt_volume.storage-qcow2[count.index].id}"
  }

  disk {
    volume_id = "${libvirt_volume.nfs-storage[count.index].id}"
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

  depends_on = [ libvirt_network.swarm ]
}

# wait until VMs become ready
resource "terraform_data" "storage-up" {
  count = var.number_of_storages

  # delete known_hosts.old
  provisioner "local-exec" {
   command = "rm -f ~/.ssh/known_hosts.old" 
  }

  # deletes old hostkey
  provisioner "local-exec" {
    command = "ssh-keygen -f ~/.ssh/known_hosts -R ${join("", [var.storage_subdomain, count.index + 1, var.domain_name])}"
  }

  # waits util ssh becomes ready
  provisioner "local-exec" {
    command = "until nc -zv ${join("", [var.storage_subdomain, count.index + 1, var.domain_name])} 22; do sleep 15; done"
  }

  # adds new ssh hostkeys
  provisioner "local-exec" {
    command = "ssh-keyscan -t rsa -H ${join("", [var.storage_subdomain, count.index + 1, var.domain_name])} >> ~/.ssh/known_hosts"
  }

  depends_on = [ libvirt_domain.storage ]
}
