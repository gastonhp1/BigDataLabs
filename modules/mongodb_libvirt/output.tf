output "ip" {
  value = libvirt_domain.mongodb-vm.network_interface[0].addresses[0]
}
