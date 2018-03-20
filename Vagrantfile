# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrant version: 2.0.2
# Virtual Box version: 5.1

UBUNTU_BOX = 'ubuntu/xenial64' # version '20180215.0.0', (GNU/Linux 4.4.0-112-generic x86_64)
NUM_WORKERS = 2
MEM_WORKERS = 512

Vagrant.configure('2') do |config|

  config.vm.define "master" do |m|
    m.vm.box = UBUNTU_BOX
    m.vm.hostname = 'master'
    m.vm.box_url = UBUNTU_BOX
    m.vm.network "private_network", ip: "172.30.56.120"
    m.vm.provider :virtualbox do |v|
      v.customize ["modifyvm", :id, "--memory", 2048]
      v.customize ["modifyvm", :id, "--cpus", 2]
      v.customize ["modifyvm", :id, "--name", "kube-master"] 
    end
    m.vm.provision "shell", path: "bootstrap.sh"
    m.vm.provision "shell", path: "master.sh"
  end

  (1..NUM_WORKERS).each do |n|
    config.vm.define "worker#{n}" do |worker|
      worker.vm.box = UBUNTU_BOX
      worker.vm.hostname = "worker#{n}"
      worker.vm.box_url = UBUNTU_BOX
      worker.vm.network 'private_network', ip: "172.30.56.12#{n}"
      worker.vm.provider :virtualbox do |v|
        v.customize ["modifyvm", :id, "--memory", MEM_WORKERS]
        v.customize ["modifyvm", :id, "--cpus", 1]
        v.customize ["modifyvm", :id, "--name", "kube-worker#{n}"]
      end
      worker.vm.provision "shell", path: "bootstrap.sh"
    end
  end

end