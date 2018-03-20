#! /bin/bash

sudo apt-get update
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    jq \
    curl \
    software-properties-common

sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

sudo add-apt-repository \
   "deb https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
   $(lsb_release -cs) \
   stable"

sudo apt-get update && sudo apt-get install -y docker-ce=$(apt-cache madison docker-ce | grep 17.03 | head -1 | awk '{print $3}')
docker version

sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF > /etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
 
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl # Last tested with versions: 1.9.5-00

cat << EOF > /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF

# Default Ubuntu ethernet interface (enp0s8) for ubuntu/xenial64 image
NODE_IP_ADDRESS=$(ip addr show dev enp0s8 | awk 'match($0,/inet (([0-9]|\.)+).* scope global enp0s8$/,a) { print a[1]; exit }')

# Default Ubuntu ethernet interface (eth0) for DO droplet
# DROPLET_IP_ADDRESS=$(ip addr show dev eth0 | awk 'match($0,/inet (([0-9]|\.)+).* scope global eth0$/,a) { print a[1]; exit }')


# Change kubelet configurations in 10-kubeadm.conf
# --node-ip
# --cgroup-driver

echo "Environment=\"KUBELET_EXTRA_ARGS=--node-ip=$NODE_IP_ADDRESS\"" >> /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
# echo "Environment=\"KUBELET_EXTRA_ARGS=--node-ip=$DROPLET_IP_ADDRESS\"" >> /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
echo "Environment=\"KUBELET_CGROUP_ARGS=--cgroup-driver=systemd\"" >> /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

sudo systemctl daemon-reload
sudo systemctl restart kubelet