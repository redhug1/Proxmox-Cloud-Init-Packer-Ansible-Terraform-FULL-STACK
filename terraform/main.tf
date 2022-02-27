# NOTE:
# if the 'terraform apply' fails and its run again ... the disc size
# read back is in megabytes which does not then agree with specifying it as for example:
# "75G" for a disc size. It reads back as "75980M" ... so a second
# 'terraform apply' says that there is a change needed.
# So, disc sizes need to be expressed in Megabytes

module "man" {
  source = "./modules-prox3"

  hostname = "man"

  vmid = 223
  cores = 4
  memory = 8192
  ssd = 1
  rootfs_size = "25600M"
  second_partition_size = "102400M"
  storage = "Data2"
}

output "man_ip" {
  value = module.man.public_ips
}

module "cw1" {
  template_name = "9110-9100-base"

  source = "./modules-prox3"

  hostname = "cw1"

  vmid = 224
  cores = 2
  memory = 8192
  ssd = 1
  rootfs_size = "25600M"

  # NOTE: This VM does not need a second partition, BUT giving it a size of "0M"
  #       caused the rootfs_size partition to NOT be set up with the desired
  #       size of 25600M
  #   ... (this as of 11th Feb 2022 - i suspect a bug in the Telmate terraform provider)
  #
  # ... So, give second partition the minimum space (to not waste space) to ensure first
  # partition is set up as desired:
  #
  second_partition_size = "4M"
  storage = "Data2"
}

output "cw1_ip" {
  value = module.cw1.public_ips
}

module "cui" {
  source = "./modules-prox3"

  hostname = "cui"

  vmid = 225
  cores = 2
  memory = 4096
  ssd = 1
  rootfs_size = "51200M"
  second_partition_size = "4M"
  storage = "Data2"
}

output "cui_ip" {
  value = module.cui.public_ips
}

module "bast" {
  template_name = "9120-9110-bastion"

  source = "./modules-prox3"

  hostname = "bast"

  vmid = 226
  cores = 2
  memory = 4096
  ssd = 0
  rootfs_size = "30720M"
  second_partition_size = "4M"
  storage = "local-lvm"
}

output "bast_ip" {
  value = module.bast.public_ips
}
