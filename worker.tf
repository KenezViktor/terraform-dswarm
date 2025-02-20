resource "libvirt_volume" "worker-qcow2" {
  count = var.number_of_workers
  name = "debian-12-worker-${count.index + 1}.qcow2"
  pool = "default"
  source = var.image
  format = "qcow2"
}

resource "libvirt_domain" "worker" {
  count = var.number_of_workers
  name = join("", [var.worker_subdomain, count.index + 1, var.domain_name])
  memory = 2048
  vcpu = 2

  network_interface {
    network_id = libvirt_network.swarm.id
    hostname = join("", [var.worker_subdomain, count.index + 1, var.domain_name])
    addresses = [ join("", [var.swarm-network.ipv4, (count.index + 201)]) ]
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

  depends_on = [ libvirt_network.swarm ]
}

# wait until VMs become ready
resource "terraform_data" "worker-up" {
  count = var.number_of_workers

  # delete known_hosts.old
  provisioner "local-exec" {
   command = "rm -f ~/.ssh/known_hosts.old" 
  }

  # deletes old hostkey
  provisioner "local-exec" {
    command = "ssh-keygen -f ~/.ssh/known_hosts -R ${join("", [var.worker_subdomain, count.index + 1, var.domain_name])}"
  }

  # waits util ssh becomes ready
  provisioner "local-exec" {
    command = "until nc -zv ${join("", [var.worker_subdomain, count.index + 1, var.domain_name])} 22; do sleep 15; done"
  }

  # adds new ssh hostkeys
  provisioner "local-exec" {
    command = "ssh-keyscan -t rsa -H ${join("", [var.worker_subdomain, count.index + 1, var.domain_name])} >> ~/.ssh/known_hosts"
  }

  depends_on = [ libvirt_domain.worker ]
}
