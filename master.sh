#! /bin/bash

# Default Ubuntu ethernet interface (enp0s8) for ubuntu/xenial64 image
NODE_IP_ADDRESS=$(ip addr show dev enp0s8 | awk 'match($0,/inet (([0-9]|\.)+).* scope global enp0s8$/,a) { print a[1]; exit }')

CALICO_NETWORK_CIDR="192.168.0.0/16"
# FLANNEL_NETWORK_CIDR="10.244.0.0/16"
# KUBEROUTER_NETWORK_CIDR="10.1.0.0/16"

OUTPUT_FILE="kubeadmjoin.sh"

# Initialize with Calico Network CIDR
kubeadm init --apiserver-advertise-address=${NODE_IP_ADDRESS} --pod-network-cidr=${CALICO_NETWORK_CIDR} | grep "kubeadm join" > ${OUTPUT_FILE}

export KUBECONFIG=/etc/kubernetes/admin.conf
chmod 644 /etc/kubernetes/admin.conf

kubectl apply -f https://docs.projectcalico.org/v3.0/getting-started/kubernetes/installation/hosted/kubeadm/1.7/calico.yaml

# kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
# kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.9.1/Documentation/kube-flannel.yml
# kubectl apply -f https://raw.githubusercontent.com/cloudnativelabs/kube-router/master/daemonset/kubeadm-kuberouter.yaml
# export kubever=$(kubectl version | base64 | tr -d '\n')
# kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$kubever"