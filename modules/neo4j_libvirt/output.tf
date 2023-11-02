output "ip" {
  value = libvirt_domain.neo4j-vm.network_interface[0].addresses[0]
}