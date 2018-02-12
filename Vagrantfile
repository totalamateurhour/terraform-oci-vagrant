# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ol74latest"
  config.vm.box_url = "https://yum.oracle.com/boxes/oraclelinux/latest/ol7-latest.box"
  config.vm.provision "shell", path: "oci-setup.sh", privileged: false
end
