#! /bin/bash

sudo apt-get update
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    jq \
    curl \
    software-properties-common

# Default Ubuntu ethernet interface (enp0s8) for ubuntu/xenial64 image
NODE_IP_ADDRESS=$(ip addr show dev enp0s8 | awk 'match($0,/inet (([0-9]|\.)+).* scope global enp0s8$/,a) { print a[1]; exit }')
CGROUP=systemd

sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

sudo add-apt-repository \
   "deb https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
   $(lsb_release -cs) \
   stable"

# Docker Version v1.12 is recommended, but v1.11, v1.13 and 17.03
# Versions 17.06+ might work, but have not yet been tested and verified by the Kubernetes node team
sudo apt-get update && sudo apt-get install -y docker-ce=$(apt-cache madison docker-ce | grep 17.03 | head -1 | awk '{print $3}')

sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF > /etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
 
sudo apt-get update
sudo apt-get install -y kubelet=1.9.8-00   
sudo apt-get install -y kubectl=1.9.8-00
sudo apt-get install -y kubeadm=1.9.8-00 

# Docker and kubelet must use the same cgroupdriver
# systemd or cgroupfs
cat << EOF > /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=$CGROUP"]
}
EOF

# Pass bridged IPv4 traffic to iptables’ chains
# Required for Weave Net, Flannel, kube-router, Romana
# sysctl net.bridge.bridge-nf-call-iptables=1

echo "Environment=\"KUBELET_EXTRA_ARGS=--node-ip=$NODE_IP_ADDRESS\"" >> /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
echo "Environment=\"KUBELET_CGROUP_ARGS=--cgroup-driver=$CGROUP\"" >> /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

sudo systemctl daemon-reload
sudo systemctl restart kubelet