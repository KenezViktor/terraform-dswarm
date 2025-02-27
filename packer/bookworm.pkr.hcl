source "qemu" "bookworm" {
    iso_url = "${var.iso_url}"
    iso_checksum = "${var.iso_checksum}"
    output_directory = "${var.output_directory}"
    shutdown_command = "echo 'packer' | sudo -S shutdown -P now"
    disk_size = "${var.disk_size}"
    format = "qcow2"
    accelerator = "kvm"
    http_directory = "./http"
    vm_name = "${var.vm_name}"
    net_device = "virtio-net"
    disk_interface= "virtio"
    ssh_username = "root"
    #ssh_password = "${var.password}"
    ssh_clear_authorized_keys = true
    ssh_private_key_file = "${var.ssh_private_key_file}"
    ssh_timeout = "60m"
    boot_wait = "0s"
    boot_command = [
        "<wait><wait><wait><esc><wait><wait><wait>",
        "/install.amd/vmlinuz ",
        "initrd=/install.amd/initrd.gz ",
        "auto=true ",
        "hostname=${var.vm_name} ",
        "domain= ",
        "url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/${var.preseed_file} ",
        "interface=auto ",
        "vga=788 noprompt quiet --<enter>"
    ]
    qemuargs = [
        ["-m", "2048"]
    ]
}

build {
    sources = ["source.qemu.bookworm"]
}