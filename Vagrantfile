# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.boot_timeout = 1200

  # Configuracion global
  config.vm.box = "bento/ubuntu-22.04"

  # Sincronizar carpetas locales con la VM
  config.vm.synced_folder "scripts/", "/vagrant_scripts", disabled: false
  config.vm.synced_folder "configs/", "/vagrant_configs", disabled: false

  # 1. Servidor Consul Principal
  config.vm.define "consul-server" do |s1|
    s1.vm.hostname = "consul-server"
    s1.vm.network "private_network", ip: "192.168.56.10"
    s1.vm.provision "shell", path: "scripts/consul_setup.sh", args: "server"
  end

  # 2. Nodo Web 1
  config.vm.define "web-1" do |web1|
    web1.vm.hostname = "web-1"
    web1.vm.network "private_network", ip: "192.168.56.11"
    web1.vm.provision "shell", path: "scripts/node_setup.sh"
    web1.vm.provision "shell", path: "scripts/consul_setup.sh", args: ["client", "192.168.56.11"]
  end

  # 3. Nodo Web 2
  config.vm.define "web-2" do |web2|
    web2.vm.hostname = "web-2"
    web2.vm.network "private_network", ip: "192.168.56.12"
    web2.vm.provision "shell", path: "scripts/node_setup.sh"
    web2.vm.provision "shell", path: "scripts/consul_setup.sh", args: ["client", "192.168.56.12"]
  end

  # 4. Nodo Web 3
  config.vm.define "web-3" do |web3|
    web3.vm.hostname = "web-3"
    web3.vm.network "private_network", ip: "192.168.56.13"
    web3.vm.provision "shell", path: "scripts/node_setup.sh"
    web3.vm.provision "shell", path: "scripts/consul_setup.sh", args: ["client", "192.168.56.13"]
  end

  # 4. Nodo Balanceador de Carga (HAProxy)
  config.vm.define "lb-1" do |lb|
    lb.vm.hostname = "lb-1"
    lb.vm.network "private_network", ip: "192.168.56.20"
    lb.vm.provision "shell", path: "scripts/haproxy_setup.sh"
  end

end