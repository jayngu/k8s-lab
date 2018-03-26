#! /bin/bash

# Default Ubuntu ethernet interface (enp0s8) for ubuntu/xenial64 image
NODE_IP_ADDRESS=$(ip addr show dev enp0s8 | awk 'match($0,/inet (([0-9]|\.)+).* scope global enp0s8$/,a) { print a[1]; exit }')

# Default Ubuntu ethernet interface (eth0) for DO droplet
# DROPLET_IP_ADDRESS=$(ip addr show dev eth0 | awk 'match($0,/inet (([0-9]|\.)+).* scope global eth0$/,a) { print a[1]; exit }')

CALICO_NETWORK_CIDR="192.168.0.0/16"
FLANNEL_NETWORK_CIDR="10.244.0.0/16"
KUBEROUTER_NETWORK_CIDR="10.1.0.0/16"

OUTPUT_FILE="kubeadmjoin.sh"

# echo "Initializing master node with Calico..."
# kubeadm init --apiserver-advertise-address=${NODE_IP_ADDRESS} --pod-network-cidr=${CALICO_NETWORK_CIDR} | grep "kubeadm join" > ${OUTPUT_FILE}

# echo "Initializing master node with Flannel..."
# kubeadm init --apiserver-advertise-address=${NODE_IP_ADDRESS} --pod-network-cidr=${FLANNEL_NETWORK_CIDR} | grep "kubeadm join" > ${OUTPUT_FILE}

# echo "Initializing master node with kube-router..."
# kubeadm init --apiserver-advertise-address=${NODE_IP_ADDRESS} --pod-network-cidr=${KUBEROUTER_NETWORK_CIDR} | grep "kubeadm join" > ${OUTPUT_FILE}

echo "Initializing master node with Weave Net..."
kubeadm init --apiserver-advertise-address=${NODE_IP_ADDRESS} | grep "kubeadm join" > ${OUTPUT_FILE}

# kubeadm init --apiserver-advertise-address=${DROPLET_IP_ADDRESS} --pod-network-cidr=${CALICO_NETWORK_CIDR} | grep "kubeadm join" > ${OUTPUT_FILE}
# kubeadm init --apiserver-advertise-address=${DROPLET_IP_ADDRESS} | grep "kubeadm join" > ${OUTPUT_FILE}

export KUBECONFIG=/etc/kubernetes/admin.conf
chmod 644 /etc/kubernetes/admin.conf

# kubectl create secret docker-registry gitlabreg-secret --docker-server=<gitlab-server> --docker-username=<username> --docker-password=<pw> --docker-email=<email> --namespace=default

###########################################################################################
## Create the pod network for the cluster. CNI listed in the following order:
## - Calico
## - Flannel
## - kube-router
## - Weave Net
###########################################################################################

# kubectl apply -f https://docs.projectcalico.org/v3.0/getting-started/kubernetes/installation/hosted/kubeadm/1.7/calico.yaml

# kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
# kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.9.1/Documentation/kube-flannel.yml

# kubectl apply -f https://raw.githubusercontent.com/cloudnativelabs/kube-router/master/daemonset/kubeadm-kuberouter.yaml

export kubever=$(kubectl version | base64 | tr -d '\n')
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$kubever"