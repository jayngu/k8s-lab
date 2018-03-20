#! /bin/bash

# Default Ubuntu ethernet interface (enp0s8) for ubuntu/xenial64 image
NODE_IP_ADDRESS=$(ip addr show dev enp0s8 | awk 'match($0,/inet (([0-9]|\.)+).* scope global enp0s8$/,a) { print a[1]; exit }')

# Default Ubuntu ethernet interface (eth0) for DO droplet
# DROPLET_IP_ADDRESS=$(ip addr show dev eth0 | awk 'match($0,/inet (([0-9]|\.)+).* scope global eth0$/,a) { print a[1]; exit }')

CALICO_NETWORK_CIDR="192.168.0.0/16"
FLANNEL_NETWORK_CIDR="10.244.0.0/16"
KUBEROUTER_NETWORK_CIDR="10.1.0.0/16"

OUTPUT_FILE="kubeadmjoin.sh"

echo "Initializing master node..."
kubeadm init --apiserver-advertise-address=${NODE_IP_ADDRESS} --pod-network-cidr=${CALICO_NETWORK_CIDR} | grep "kubeadm join" > ${OUTPUT_FILE}
# kubeadm init --apiserver-advertise-address=${DROPLET_IP_ADDRESS} --pod-network-cidr=${CALICO_NETWORK_CIDR} | grep "kubeadm join" > ${OUTPUT_FILE}
export KUBECONFIG=/etc/kubernetes/admin.conf
chmod 644 /etc/kubernetes/admin.conf

# Set calico as CNI
kubectl apply -f https://docs.projectcalico.org/v3.0/getting-started/kubernetes/installation/hosted/kubeadm/1.7/calico.yaml
# Set flannel as CNI
#kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
# Set kube-router as CNI
#kubectl apply -f https://raw.githubusercontent.com/cloudnativelabs/kube-router/master/daemonset/kubeadm-kuberouter.yaml