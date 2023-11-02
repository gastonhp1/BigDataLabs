resource "libvirt_pool" "mongodb" {
  name = var.dbname
  type = "dir"
  path = var.poolpath
}

# Defining VM Volume
resource "libvirt_volume" "mongodb-master-qcow2" {
  name   = "${var.dbname}-master.qcow2"
  pool   = libvirt_pool.mongodb.name
  source = var.remote_iso
  format = "qcow2"
}

resource "libvirt_volume" "mongodb-worker-qcow2" {
  name           = "${var.dbname}-worker.qcow2"
  base_volume_id = libvirt_volume.mongodb-master-qcow2.id
  pool           = libvirt_pool.mongodb.name
  size           = 10737418240
}

# Defining Virtual Machine
resource "libvirt_domain" "mongodb-vm" {
  name   = "${var.dbname}-vm"
  memory = "2048"
  vcpu   = 2

  cloudinit = libvirt_cloudinit_disk.mongodb-init.id

  network_interface {
    network_name   = "default"
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.mongodb-worker-qcow2.id
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "0"
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
    host     = libvirt_domain.mongodb-vm.network_interface[0].addresses[0]
  }

  #provisioner "remote-exec" {
  #  inline = [
  #    "wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -",
  #    "sudo apt-get install gnupg",
  #    "echo 'deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse' | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list",
  #    "sudo apt-get update",
  #    "sudo apt-get install -y mongodb-org",
  #    "sudo systemctl daemon-reload",
  #    "sudo systemctl start mongod",
  #    "sudo systemctl enable mongod"
  # ]
  #}
}

data "template_file" "user_data" {
  template = file("config/cloud_init.yml")
}

resource "libvirt_cloudinit_disk" "mongodb-init" {
  name      = "mongodb-init.iso"
  user_data = data.template_file.user_data.rendered
  pool      = libvirt_pool.mongodb.name
}

resource "null_resource" "run_ansible" {
#  triggers = {
#    # Add any triggers that determine when to run this provisioner
#  }

  provisioner "local-exec" {
    command     = "ansible-playbook -i ${libvirt_domain.mongodb-vm.network_interface[0].addresses[0]} ./config/mongodb_playbook.yml"
    working_dir = path.module
  }

  depends_on = [
    libvirt_domain.mongodb-vm
  ]
}