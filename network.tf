resource "libvirt_network" "swarm" {
  name = "swarm"
  mode = "nat"

  domain = var.domain_name
  addresses = [ join("" ,[var.swarm-network.network, var.swarm-network.netmask]) ]

  dhcp {
    enabled = false
  }

  dns {
    enabled = true
  }
}