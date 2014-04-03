# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = '2'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = 'debian-73-i386-virtualbox-puppet'
  config.vm.box_url = 'http://puppet-vagrant-boxes.puppetlabs.com/debian-73-i386-virtualbox-puppet.box'

  config.vm.provider :virtualbox do |vb|
    vb.customize ['modifyvm', :id, '--memory', '1024']

    # Speed up networking on Mac OS X
    vb.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
  end

  config.vm.provision :shell, inline: 'apt-get update'
  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = './'
    puppet.manifest_file = 'vagrant.pp'
    puppet.module_path = %w(modules ../)
  end

  config.vm.define 'server' do |node|
    node.vm.hostname = 'monitoring.example.com'
    node.vm.network :private_network, ip: '10.35.107.132'

  end

  config.vm.define 'client' do |node|
    node.vm.hostname = 'client.example.com'
    node.vm.network :private_network, ip: '10.35.107.133'
  end
end
