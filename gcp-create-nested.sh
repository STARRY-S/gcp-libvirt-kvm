#!/bin/bash
#

set -euo pipefail

INSTANCE_NAME='starry-kvm-1' # 实例名称
INSTANCE_TEMPLATE='starry-kvm-debian-8c16g' # 实例 Template

echo "Creating Instance ${INSTANCE_NAME}"
echo "Using template: $INSTANCE_TEMPLATE"

set -x
gcloud compute instances create ${INSTANCE_NAME} \
  --enable-nested-virtualization \
  --zone="asia-northeast1-b"  \
  --min-cpu-platform="Intel Haswell" \
  --source-instance-template="projects/ei-container-platform-dev/regions/asia-northeast1/instanceTemplates/$INSTANCE_TEMPLATE" \
  --custom-cpu=12 \
  --custom-memory=22G \
  --boot-disk-size="200G" \
  --provisioning-model=SPOT

  # --machine-type="n1-standard-16" \

# starry-kvm-debian-8c16g: 8C 16G Debian 12, can run 3 nested KVM
# starry-kvm-ubuntu-8c16g: 8C 16G Ubuntu 20.04 LTS, can run 3 nested KVM

  # Other options:
  # --machine-type="n1-standard-16" \
  # --boot-disk-size="100G" \ # 磁盘大小
  # --provisioning-model=SPOT \ # 使用 SPOT 实例
