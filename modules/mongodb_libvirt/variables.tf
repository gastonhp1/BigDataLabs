variable "dbname" {
  description = "mongodb vm name"
  type        = string
  default     = "mongodb"
}

variable "poolpath" {
  description = "The path where the libvirt pool is located"
  type        = string
  default     = "/var/kvm/mongodb"
}

variable "remote_iso" {
  description = "The url of the operating system image"
  type        = string
  default     = "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img"
}

variable "mem" {
  description = "mongodb vm memory size"
  type        = string
  default     = "2048"
}

variable "vcpu" {
  description = "mongodb vm vcpus"
  type        = number
  default     = 4
}

#variable "ansibe_repo_name" {
#  description = "Repo ansible mongodb playbook instalation name"
#  type        = string
#  default     = "ansible-mongodb"
#}

#variable "ansibe_repo" {
#  description = "Repo ansible mongodb playbook instalation"
#  type        = string
#  default     = "https://github.com/gastonhp1/ansible-mongodb/"
#}

variable "ssh_username" {
  description = "User"
  type        = string
  default     = "gastonhp1"
}

variable "password" {
  description = "Password"
  type        = string
  default     = "Pass.123!"
}

variable "mongodb_instances" {
  description = "List of MongoDB instance variables"
  type = list(object({
    id              = number
    port            = number
    data_dir        = string
    config_template = string
  }))
  default = [
    { id = 0, port = 27017, data_dir = "/var/lib/mongodb1", config_template = "mongod1.conf.j2" },
    { id = 1, port = 27018, data_dir = "/var/lib/mongodb2", config_template = "mongod2.conf.j2" },
    { id = 2, port = 27019, data_dir = "/var/lib/mongodb3", config_template = "mongod3.conf.j2" },
  ]
}
