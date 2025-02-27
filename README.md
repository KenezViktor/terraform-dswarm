# Terraform-dswarm

## Setup the environment

The following steps asume the host runs Debian

### Install Packer, Terraform, Ansible, Qemu/KVM and libvirt

Run the command below:
```
apt update
apt install -y gnupg software-properties-common
curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt update
apt install -y terraform packer ansible ansible-core qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virtinst libvirt-daemon
```

Note: Terraform migth not be able to create VMs due to permission denied. To fix it, edit the ```/etc/libvirt/qemu.conf``` file at:
```
#security_driver = "selinux"
```
and change it to:
```
security_driver = "none"
```

Dont forget to restart related services

## Create disk image, VMs and the Swarm

### Create disk image

1) Generate ssh keypair named packer_key

```
ssh-keygen
```

After that, edit the ```http/preseed.conf``` file at the end to place your pubkey under root's authorized_keys.

When accessing VMs later, use the following command:
```
ssh -i /path/to/.ssh/private root@vm.local
```

Note: If your ssh key has not passphrase, you can use it, but change the ```ssh_private_key_file``` var's value.

2) Run script to build image

@param1: packer output dir
@param2: final destination, should be ```/var/lib/libvirt/images```
@param3: vm_name, name of OS image

```
cd packer/
./run.sh @param1 @param2 @param3
cd ..
```

The script init and build the packer project then copies the OS image to libvirt's env and deletes the output dir to allow re-run.

### Create VMs

1) Edit ```/etc/hosts```

If this project is about to be run locally, create the following domain entries:
```
# Terraform Docker Swarm
# Managers
192.168.150.101 manager-1.office.lab
192.168.150.102 manager-2.office.lab
# Workers
192.168.150.201 worker-1.office.lab
192.168.150.202 worker-2.office.lab
192.168.150.203 worker-3.office.lab
192.168.150.204 worker-4.office.lab
# Storage
192.168.150.51  storage-1.office.lab

# Services
192.168.150.100 vrrp.office.lab
192.168.150.100 grafana.office.lab
```

Note: edit network.tf if 192.168.150.0/24 is already used elsewhere

2) Init terraform project

```
terraform init
```

3) Install Ansible collection

```
ansible-galaxy collection install -r ansible-playbooks/requirements.yml
```

4) Apply terraform

```
terraform plan
terraform apply -auto-approve
```

## Apply Ansible

### Init Swarm

```
ansible-playbook -i ./inventory.yaml --diff ansible-playbooks/swarm-init/swarm.yaml
```


## Included Services

### Cluster Monitoring

Grafana<br>
Prometheus<br>
cAdvisor<br>

### HA, VRRP

HAProxy<br>
Keepalived<br>