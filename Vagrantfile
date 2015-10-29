# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  config.vm.box = "centos65"
  config.vm.box_url ="http://www.lyricalsoftware.com/downloads/centos65.box"
  config.vm.hostname = 'dashboard-server'
  config.vm.network "forwarded_port", guest: 8153, host: 8153
  config.vm.network "forwarded_port", guest: 4567, host: 4567
  config.berkshelf.enabled = true

  config.vm.provision "chef_solo" do |chef|
    chef.add_recipe "rbenv"
  end

  config.vm.provider "virtualbox" do |v|
    v.memory = 2048
  end

end
