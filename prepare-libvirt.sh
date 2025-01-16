#!/bin/bash

cd $(dirname $0)/
WORKDIR=$(pwd)

set -exuo pipefail

# Update $PATH
if ! cat ~/.bashrc | grep -q '/usr/sbin'; then
    echo 'export PATH=$PATH:/usr/sbin' >> ~/.bashrc
fi

CLOUD_IMG="https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img"
LIBVIRT_PATH="/var/lib/libvirt"

sudo apt-get update
sudo apt-get -y install virt-manager cloud-image-utils

echo "Initializing libvirt default network"

DEFAULT_NETWORK_UUID=$(sudo virsh net-dumpxml default | grep '<uuid>' | sed -e 's/^[[:space:]]*//')
DEFAULT_NETWORK_UUID=${DEFAULT_NETWORK_UUID##'<uuid>'}
DEFAULT_NETWORK_UUID=${DEFAULT_NETWORK_UUID%%'</uuid>'}
cp default-network-template.xml default-network.xml
sed -i "s/DEFAULT_NETWORK_UUID/${DEFAULT_NETWORK_UUID}/g" default-network.xml
echo "Update default network XML:"
cat default-network.xml

sudo virsh net-destroy default || true
sudo virsh net-define ./default-network.xml
sudo virsh net-autostart default || true
sudo virsh net-start default

if ! grep -q '10.128.0.101' /etc/hosts; then
    sudo bash -c "echo '10.128.0.101   ubuntu-1' >> /etc/hosts"
    sudo bash -c "echo '10.128.0.102   ubuntu-2' >> /etc/hosts"
    sudo bash -c "echo '10.128.0.103   ubuntu-3' >> /etc/hosts"
fi

echo "Initializing libvirt vtpm secret"
sudo virsh secret-define ./vtpm-secret.xml
MYSECRET=`printf %s "open sesame" | base64`
sudo virsh secret-set-value 9a2e9101-6bf8-42e2-885b-ab26a4c33ab7 $MYSECRET
sudo mkdir -p $LIBVIRT_PATH/images
sudo mkdir -p $LIBVIRT_PATH/nvram # UEFI boot nvram
# Grant read permission for other users
sudo chmod -R 755 $LIBVIRT_PATH
cd $LIBVIRT_PATH/images

if [[ -e ubuntu-1.qcow2 ]]; then
    echo "Ubuntu qcow2 image already exists, exit."
    exit 0
fi

# Download
echo "Downloading the ubuntu KVM image..."
if [[ ! -e 'ubuntu.img' ]]; then
    sudo wget $CLOUD_IMG -O ubuntu.img
fi
sudo cp ubuntu.img ubuntu-1.qcow2
sudo cp ubuntu.img ubuntu-2.qcow2
sudo cp ubuntu.img ubuntu-3.qcow2
echo "Resize ubuntu qcow2 disk image to 40G"
sudo qemu-img resize ubuntu-1.qcow2 40G
sudo qemu-img resize ubuntu-2.qcow2 40G
sudo qemu-img resize ubuntu-3.qcow2 40G

cd $WORKDIR
echo "Create user-data"
cloud-localds userdata-1.img userdata-1.yaml
cloud-localds userdata-2.img userdata-2.yaml
cloud-localds userdata-3.img userdata-3.yaml
sudo mv ./*.img $LIBVIRT_PATH/images

echo "Define libvirt VM XML domains"
sudo virsh define ./ubuntu-1.xml
sudo virsh define ./ubuntu-2.xml
sudo virsh define ./ubuntu-3.xml

# Ensure IPv6 VM connections
sudo ip6tables -P FORWARD ACCEPT

set +x
sudo virsh list --all

echo "Use 'virsh start ubuntu-N' to boot up
Use 'virsh shutdown ubuntu-N' to shutdown
Use 'virsh destroy ubuntu-N' to force shutdown
Use 'ssh root@10.128.0.10N' to connect the VM
Done"
