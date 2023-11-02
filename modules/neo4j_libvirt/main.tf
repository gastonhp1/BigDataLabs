provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_pool" "neo4j" {
  name = var.dbname
  type = "dir"
  path = var.poolpath
}

# Defining VM Volume
resource "libvirt_volume" "neo4j-master-qcow2" {
  name   = "${var.dbname}-master.qcow2"
  pool   = libvirt_pool.neo4j.name
  source = var.remote_iso
  format = "qcow2"
}

resource "libvirt_volume" "neo4j-worker-qcow2" {
  name            = "${var.dbname}-worker.qcow2"
  base_volume_id  = libvirt_volume.neo4j-master-qcow2.id
  pool            = libvirt_pool.neo4j.name
  size            = 10737418240
}

# Defining Virtual Machine
resource "libvirt_domain" "neo4j-vm" {
  name   = "${var.dbname}-vm"
  memory = var.mem
  vcpu   = var.vcpu

  cloudinit = libvirt_cloudinit_disk.neo4j-init.id

  network_interface {
    network_name   = "default"
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.neo4j-worker-qcow2.id
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }

  connection {
    type     = "ssh"
    user     = var.ssh_username
    password = var.password
    host     = libvirt_domain.neo4j-vm.network_interface[0].addresses[0]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y ansible"
    ]
  }
}

data "template_file" "user_data" {
  template = file("config/cloud_init.yml")
}

data "template_file" "network_config" {
  template = file("config/network_config.yml")
}

resource "libvirt_cloudinit_disk" "neo4j-init" {
  name           = "neo4j-init.iso"
  user_data      = data.template_file.user_data.rendered
  pool           = libvirt_pool.neo4j.name
}

resource "null_resource" "neo4j-playbook" {

  connection {
    type     = "ssh"
    user     = var.ssh_username
    password = var.password
    host     = libvirt_domain.neo4j-vm.network_interface[0].addresses[0]
  }

  provisioner "local-exec" {
    command = "scp -o 'StrictHostKeyChecking no' ${var.ansible_playbook} ${libvirt_domain.neo4j-vm.network_interface[0].addresses[0]}:"
  }

  provisioner "remote-exec" {
    inline = [
      "ansible-playbook install_neo4j.yml"
    ]
  }

  depends_on = [
    libvirt_domain.neo4j-vm
  ]
}
