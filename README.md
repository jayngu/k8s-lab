# What will we accomplish?

The following guide allows you to setup a multi-node Kubernetes cluster with Vagrant. The final result:
- 1 Master Node
- 2 Worker Nodes
- Last tested with: Kubernetes version 1.9.8
- Calico Overlay Network

## Prerequisites

- Preferrably a UNIX based machine
- Vagrant and VirtualBox installed
- As much RAM as possible. The inital setup takes around 4 GB 

## Getting Started

```
git clone https://github.com/jayngu/k8s-lab
cd ~/k8s-lab
```

Initialize vagrant machines and get coffee.
```
~/k8s-lab$ vagrant up
```

Check vagrant machine status.
```
$ vagrant status

Current machine states:

master                    running (virtualbox)
worker1                   running (virtualbox)
worker2                   running (virtualbox)
```

SSH into the master node / worker nodes
```
$ vagrant ssh master
$ vagrant ssh worker1
$ vagrant ssh worker2
```

On the master node, we must specify the config file kubecontrol can use.
```
export KUBECONFIG=/etc/kubernetes/admin.conf
```

On the master node, copy the **kubeadmjoin.sh** file on to your clipboard. This token command was output during the kubeadm process and allows nodes to join the k8s cluster.
```
vagrant@master:~$ cat kubeadmjoin.sh 
  kubeadm join --token 10d3fc.04d4923ddf08bd89 172.30.56.120:6443 --discovery-token-ca-cert-hash sha256:95d0c1a67f6f65c2c52d0fe450a50861a66d9a7916c0db888fc0014d636f1b3b
```

On each worker node, join the k8s cluster with the above command. It should look like this:
```
vagrant@worker1:~$ sudo kubeadm join --token 10d3fc.04d4923ddf08bd89 172.30.56.120:6443 --discovery-token-ca-cert-hash sha256:95d0c1a67f6f65c2c52d0fe450a50861a66d9a7916c0db888fc0014d636f1b3b
[preflight] Running pre-flight checks.
	[WARNING FileExisting-crictl]: crictl not found in system path
[discovery] Trying to connect to API Server "172.30.56.120:6443"
[discovery] Created cluster-info discovery client, requesting info from "https://172.30.56.120:6443"
[discovery] Requesting info from "https://172.30.56.120:6443" again to validate TLS against the pinned public key
[discovery] Cluster info signature and contents are valid and TLS certificate validates against pinned roots, will use API Server "172.30.56.120:6443"
[discovery] Successfully established connection with API Server "172.30.56.120:6443"

This node has joined the cluster:
* Certificate signing request was sent to master and a response
  was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the master to see this node join the cluster.
```

Check node status on the master: **kubectl get nodes**
```
NAME      STATUS    ROLES     AGE       VERSION
master    Ready     master    18m       v1.9.8
worker1   Ready     <none>    8m        v1.9.8
worker2   Ready     <none>    8m        v1.9.8
```

Check pod status on the master: **kubectl get pods --all-namespaces -o wide**
```
NAMESPACE     NAME                                       READY     STATUS    RESTARTS   AGE       IP               NODE
kube-system   calico-etcd-v555b                          1/1       Running   0          10m       172.30.56.120    master
kube-system   calico-kube-controllers-559b575f97-p98cx   1/1       Running   0          10m       172.30.56.120    master
kube-system   calico-node-vf5zn                          2/2       Running   1          1m        172.30.56.121    worker1
kube-system   calico-node-wbx9j                          2/2       Running   0          10m       172.30.56.120    master
kube-system   calico-node-xwxxz                          2/2       Running   1          1m        172.30.56.122    worker2
kube-system   etcd-master                                1/1       Running   0          10m       172.30.56.120    master
kube-system   kube-apiserver-master                      1/1       Running   0          10m       172.30.56.120    master
kube-system   kube-controller-manager-master             1/1       Running   0          10m       172.30.56.120    master
kube-system   kube-dns-6f4fd4bdf-v8rm9                   3/3       Running   0          10m       192.168.219.65   master
kube-system   kube-proxy-2thtr                           1/1       Running   0          1m        172.30.56.122    worker2
kube-system   kube-proxy-49kmh                           1/1       Running   0          10m       172.30.56.120    master
kube-system   kube-proxy-7qdb7                           1/1       Running   0          1m        172.30.56.121    worker1
kube-system   kube-scheduler-master                      1/1       Running   0          10m       172.30.56.120    master
```

Have fun deploying services!