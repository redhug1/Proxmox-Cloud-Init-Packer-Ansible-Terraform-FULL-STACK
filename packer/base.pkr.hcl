variable "proxmox_host_node" {
  type    = string
}

variable "proxmox_token" {
  type      = string
  sensitive = true
}

variable "proxmox_url" {
  type    = string
}

variable "proxmox_username" {
  type    = string
}

source "proxmox-clone" "test-cloud-init" {
  insecure_skip_tls_verify = true
  full_clone = false

  # Temporary name used during image creation:
  vm_name = "base-temp"

  # source VM:
  clone_vm      = "ubuntu2004-cloud"

  # output template name:
  # The structure of the name is:
  # "<output VMID>-<input VMID>-<template human form name>"
  template_name = "9110-9100-base"

  # output template id
  vm_id = 9110

  os              = "l26"
  cores           = "2"
  memory          = "4096"
  scsi_controller = "virtio-scsi-pci"

  ssh_username = "ubuntu"
  qemu_agent = true

  network_adapters {
    bridge = "vmbr0"
    model  = "virtio"
  }

  node          = "${var.proxmox_host_node}"
  username      = "${var.proxmox_username}"
  token         = "${var.proxmox_token}"
  proxmox_url   = "${var.proxmox_url}"
}

build {
  sources = ["source.proxmox-clone.test-cloud-init"]

  provisioner "shell" {
    inline         = [
#      "sudo less /etc/passwd",
#      "sudo cloud-init clean",
      "sudo ip add",
      "hostname -I",
      "echo 'Start waiting for cloud-init...'",
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
      "echo 'Start waiting for dpkg/lock...'",
      "timeout 60s bash -c \"while sudo fuser /var/lib/dpkg/lock > /dev/null 2>&1; do echo 'Waiting for dpkg lock to be free...'; sleep 2; done\""
    ]
  }

  provisioner "ansible" {
    playbook_file = "${path.root}/../ansible/base.yml"
    extra_arguments = [
      "--diff",
      "--extra-vars", "ansible_python_interpreter=/usr/bin/python3"
    ]
  }

#  provisioner "shell" {
#    inline         = [
#      "rm .ssh/authorized_keys; sudo rm /root/.ssh/authorized_keys"
#    ]
#  }
}
