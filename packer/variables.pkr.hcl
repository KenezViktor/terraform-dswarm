/* variable template for easy copy-paster
variable "" {
    type = 
    default = 
}
*/

# build specific vars
variable "iso_url" {
    type = string
    default = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.9.0-amd64-netinst.iso"
}

variable "iso_checksum" {
    type = string
    default = "1257373c706d8c07e6917942736a865dfff557d21d76ea3040bb1039eb72a054"
}

variable "disk_size" {
    type = string
    default = "10G"
}

variable "vm_name" {
    type = string
    default = "bookworm-packer"
}

variable "password" {
    type = string
    default = "password"
}

variable "output_directory" {
    type = string
    default = "/tmp/packer-output"
}

variable "preseed_file" {
    type = string
    default = "preseed.conf"
}

variable "ssh_private_key_file" {
    type = string
    default = "~/.ssh/packer_key"
}
