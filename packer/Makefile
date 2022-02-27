ansible_roles_path := ../ansible/roles

.PHONY: base
base:
#	ANSIBLE_ROLES_PATH=$(ansible_roles_path) packer build --var-file=./proxmox.pkvars.hcl base.pkr.hcl
	packer build --var-file=./proxmox.pkvars.hcl base.pkr.hcl

.PHONY: bastion
bastion:
	packer build --var-file=./proxmox.pkvars.hcl bastion.pkr.hcl
