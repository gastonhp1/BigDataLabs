variable "dbname" {
  description = "Neo4j vm name"
  type        = string
  default     = "neo4j"
}

variable "poolpath" {
  description = "The path where the libvirt pool is located"
  type        = string
  default     = "/var/kvm/neo4j"
}

variable "remote_iso" {
  description = "The url of the operating system image"
  type        = string
  default     = "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img"
}

variable "mem" {
  description = "Neo4j vm memory size"
  type        = string
  default     = "1024"
}

variable "vcpu" {
  description = "Neo4j vm vcpus"
  type        = number
  default     = 2
}

variable "ansibe_repo_name" {
  description = "Repo ansible neo4j playbook instalation name"
  type        = string
  default     = "ansible-neo4j"
}

variable "ansibe_dir" {
  description = "Dir ansible neo4j playbook instalation"
  type        = string
  default     = "~/"
}

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

variable "ansible_playbook" {
  description = "Playbook file for neo4j install"
  type        = string
  default     = "./config/install_neo4j.yml"
}
