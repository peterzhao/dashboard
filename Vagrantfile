# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  config.vm.box = "centos65"
  config.vm.box_url ="http://www.lyricalsoftware.com/downloads/centos65.box"
  config.vm.hostname = 'dashboard-server'
  config.vm.network "forwarded_port", guest: 4567, host: 4567
  config.vm.network "forwarded_port", guest: 2525, host: 2525
  config.vm.network "forwarded_port", guest: 4545, host: 4545
  config.vm.network "forwarded_port", guest: 8153, host: 8153
  config.vm.network "forwarded_port", guest: 8080, host: 8888
  config.berkshelf.enabled = true

  config.vm.provision "chef_solo" do |chef|
    chef.add_recipe "tools::rbenv"
    chef.add_recipe "tools::mounte_bank"
    chef.add_recipe "tools::tmate"
    chef.add_recipe "tools::vim"
    chef.add_recipe "tools::phantomjs_libs"
    chef.add_recipe "tools::xvfb"
    chef.add_recipe "gocd_cookbook"
    chef.add_recipe "jenkins_cookbook"
  end

  config.vm.provider "virtualbox" do |v|
    v.memory = 2048
  end

end
