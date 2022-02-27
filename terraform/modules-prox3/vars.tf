variable "ssh_key" {
  default = "ssh-rsa <your text here>== rhys@run3"
}

variable "proxmox_host" {
  default = "prox3"
}

variable "template_name" {
  default = "ubuntu2004-cloud"
}

variable "vmid" {
  default     = 159
  description = "Starting ID for the CTs, and also the IP address within the subnet"
}

variable "hostname" {
  description = "VMs to be created"
  type        = string
  default     = "t1"
}

variable "cores" {
  default = 2
}

variable "memory" {
  default = 4096
}

variable "rootfs_size" {
  type    = string
  default = "10240M"
}

variable "second_partition_size" {
  type    = string
  default = "4M"
}

variable "storage" {
  type    = string
  default = "Data1"
}

variable "ssd" {
  default = 0
}

variable "tags" {
  type    = string
  default = "tag1"
}

variable "ip" {
  type = string
  default = "192.168.124.159"
}
