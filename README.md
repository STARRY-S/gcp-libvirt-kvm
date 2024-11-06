# GCP libvirt KVM

创建 GCP KVM 嵌套虚拟化实例，并在其中启动 libvirt 嵌套虚拟机。

## Usage

```sh
git clone https://github.com/STARRY-S/gcp-libvirt-kvm.git && cd gcp-libvirt-kvm/
```

## Launch GCP instance

创建 GCP KVM 嵌套虚拟化实例。

```sh
vim ./gcp-create-nested.sh # 编辑实例名称，并按需要调整实例 Template 以及启动参数
./gcp-create-nested.sh
```

## Launch libvirt VM

GCP 虚拟机创建成功后，SSH 进入 GCP 虚拟机中，执行脚本安装 libvirt 并启动虚拟机实例。

```sh
git clone https://github.com/STARRY-S/gcp-libvirt-kvm.git && cd gcp-libvirt-kvm/

# 执行脚本在 GCP 实例中安装 libvirt，并创建 KVM 嵌套虚拟机
./prepare-libvirt.sh
```

等待 Libvirt 安装，创建嵌套虚拟机。

脚本执行完成后，创建的虚拟机为：

```console
$ sudo virsh list --all
 Id   Name       State
--------------------------
 1    ubuntu-1   running
 2    ubuntu-2   running
 3    ubuntu-3   running
```

创建的三个虚拟机名称分别为 `ubuntu-1`, `ubuntu-2`, `ubuntu-3`，
可使用 `virsh` 操作这些虚拟机。

```sh
sudo virsh start ubuntu-1       # 启动虚拟机
sudo virsh shutdown ubuntu-1    # 虚拟机关机
```

可通过 IP 地址 SSH 到虚拟机中，三个虚拟机对应的 IP 地址为：

```console
$ ssh ubuntu@10.128.0.101
$ ssh ubuntu@10.128.0.102
$ ssh ubuntu@10.128.0.103
```
