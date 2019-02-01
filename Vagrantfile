# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"

  config.vm.provider "virtualbox" do |v|
    v.memory = 4096
    v.cpus = 2
  end

  config.disksize.size = '60GB'
  config.vm.network "forwarded_port", guest: 8080, host: 8080
  config.vm.provision "shell", path: "install-concourse.sh"
end
