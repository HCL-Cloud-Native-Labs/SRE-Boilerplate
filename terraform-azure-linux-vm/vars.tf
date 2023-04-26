# required variables
variable "hostname" {
  description = "name of the machine to create"
}

variable "name_prefix" {
  description = "unique part of the name to give to resources"
}

variable "ssh_public_key" {
  description = "public key for ssh access"
}

# optional variables
variable "location" {
  description = "region where the resources should exist"
  default     = "eastus"
}

variable "vnet_address_space" {
  description = "full address space allowed to the virtual network"
  default     = "10.0.0.0/16"
}

variable "subnet_address_space" {
  description = "the subset of the virtual network for this subnet"
  default     = "10.0.10.0/24"
}

variable "storage_account_type" {
  description = "type of storage account"
  default     = "Standard_LRS"
}

variable "vm_size" {
  description = "size of the vm to create"
  default     = "Standard_A0"
}

variable "image_publisher" {
  description = "name of the publisher of the image (az vm image list)"
  default     = "Canonical"
}

variable "image_offer" {
  description = "the name of the offer (az vm image list)"
  default     = "UbuntuServer"
}

variable "image_sku" {
  description = "image sku to apply (az vm image list)"
  default     = "16.04-LTS"
}

variable "image_version" {
  description = "version of the image to apply (az vm image list)"
  default     = "latest"
}

variable "admin_username" {
  description = "administrator user name"
  default     = "vmadmin"
}

variable "admin_password" {
  description = "administrator password (recommended to disable password auth)"
  default     = "notused"
}

variable "disable_password_authentication" {
  description = "toggle for password auth (recommended to keep disabled)"
  default     = true
}
