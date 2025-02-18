resource "libvirt_volume" "worker-qcow2" {
  count = var.number_of_workers
  name = "debian-12-worker-${count.index}.qcow2"
  pool = "default"
  source = var.image
  format = "qcow2"
}

resource "libvirt_domain" "worker" {
  count = var.number_of_workers
  name = join("", [var.worker_subdomain, count.index, var.domain_name])
  memory = 2048
  vcpu = 2

  network_interface {
    network_id = libvirt_network.worker.id
    hostname = join("", [var.worker_subdomain, count.index, var.domain_name])
    addresses = [ join("", [var.worker-network.ipv4, (count.index + 200)]) ]
  }

  disk {
    volume_id = "${libvirt_volume.worker-qcow2[count.index].id}"
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

  depends_on = [ libvirt_network.worker ]
}

# wait until VMs become ready
resource "terraform_data" "worker-up" {
  count = var.number_of_workers

  # deletes old hostkey
  provisioner "local-exec" {
    command = "ssh-keygen -f ~/.ssh/known_hosts -R ${join("", [var.worker_subdomain, count.index, var.domain_name])}"
  }

  # waits util ssh becomes ready
  provisioner "local-exec" {
    command = "until nc -zv ${join("", [var.worker_subdomain, count.index, var.domain_name])} 22; do sleep 15; done"
  }

  # adds new ssh hostkeys
  provisioner "local-exec" {
    command = "ssh-keyscan -t rsa -H ${join("", [var.worker_subdomain, count.index, var.domain_name])} >> ~/.ssh/known_hosts"
  }

  depends_on = [ libvirt_domain.worker ]
}
