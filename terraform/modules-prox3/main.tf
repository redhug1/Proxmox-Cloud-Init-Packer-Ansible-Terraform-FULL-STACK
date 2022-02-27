terraform {
  required_version = "~> 1.1.5"
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "2.9.5"
    }
  }
}

provider "proxmox" {
  # url is the hostname (FQDN if you have one) for the proxmox host you'd like to connect to to issue the commands. my proxmox host is 'prox-1u'. Add /api2/json at the end for the API
  pm_api_url = "https://192.168.124.161:8006/api2/json"
  # api token id is in the form of: <username>@pam!<tokenId>
  pm_api_token_id = "terraform_blog@pam!new_token_id"
  # this is the full secret wrapped in quotes. don't worry, I've already deleted this from my proxmox cluster by the time you read this post
  pm_api_token_secret = "<your value here>"
  # leave tls_insecure set to true unless you have your proxmox SSL certificate situation fully sorted out (if you do, you will know)
  pm_tls_insecure = true
}

locals {
  ips = "192.168.124.${var.vmid}"
}

# resource is formatted to be "[type]" "[entity_name]" so in this case
# we are looking to create a proxmox_vm_qemu entity named test_server
resource "proxmox_vm_qemu" "test_server" {
  name = var.hostname
  target_node = var.proxmox_host
  # another variable with contents "ubuntu-2004-cloudinit-template"
  clone = var.template_name
  vmid = var.vmid
  full_clone = true
  # basic VM settings here. agent refers to guest agent
  agent = 1
  os_type = "cloud-init"
  cores = var.cores
  sockets = 1
  numa = true
  cpu = "host"
  memory = var.memory
  scsihw = "virtio-scsi-pci"

  onboot = true # !!! change this to true if eventually want all machines to start at power up

  bootdisk = "scsi0"

  disk {
    # set disk size here. leave it small for testing because expanding the disk takes time.
    ssd = var.ssd
    size = var.rootfs_size
    type = "scsi"
    storage = var.storage
    iothread = 1
  }

  disk {
    # set disk size here. leave it small for testing because expanding the disk takes time.
    ssd = var.ssd
    size = var.second_partition_size
    type = "scsi"
    storage = var.storage
    iothread = 1
  }

  nameserver = "192.168.124.162"

  # if you want two NICs, just copy this whole network section and duplicate it
  network {
    model = "virtio"
    bridge = "vmbr0"
  }
  # not sure exactly what this is for. presumably something about MAC addresses and ignore network changes during the life of the VM
  lifecycle {
    ignore_changes = [
      network,
    ]
  }

  # Cloud Init Settings
  ipconfig0 = "ip=${local.ips}/24,gw=192.168.124.1"

  # sshkeys set using variables. the variable contains the text of the key.
  # NOTE: this puts the key into the default 'ubuntu' user in file /home/ubuntu/.ssh/authorized_keys
  sshkeys = <<EOF
  ${var.ssh_key}
  EOF

  connection {
    type = "ssh"
    user = "ubuntu"
    # specify the key from 'this' host machine to establish ssh connection
    private_key = file("~/.ssh/id_rsa")
    agent = false
    timeout = "3m"
    host = "${local.ips}"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Cool: ${var.hostname} :is ready for ansible'",
      "ls -alt /home",
      # NOTE: the following shows that user rhys has the key from the original user on the proxmox hypervisor
      # when the template was created that this terraform script uses as its 'base' image
      "sudo cat /home/rhys/.ssh/authorized_keys",
      # So, now we replace with the key that we actually want that was placed in the user 'ubuntu'
      # via the 'sshkeys' directive earlier on
      "sudo cp /home/ubuntu/.ssh/authorized_keys /home/rhys/.ssh/authorized_keys",
      # and show again to confirm change
      "sudo cat /home/rhys/.ssh/authorized_keys"
    ]
  }

  tags = "${var.hostname}"
}
