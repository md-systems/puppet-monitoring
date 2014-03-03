# == Class: monitoring::sensu
#
# === Examples
#
#  class { 'monitoring::sensu': }
#
# === Authors
#
# Christian Haeusler <christian.haeusler@md-systems.ch>
#
# === Copyright
#
# Copyright 2014 MD Systems.
#
class monitoring::sensu (
  $rabbitmq_password,
  $rabbitmq_vhost = 'sensu',
  $rabbitmq_user = 'sensu'
) {
  class {'redis': }
  class {'rabbitmq':
    delete_guest_user => true,
  }

  rabbitmq_user { $rabbitmq_user:
    admin    => true,
    password => $rabbitmq_password,
  }

  rabbitmq_vhost { $rabbitmq_vhost:
    ensure => present,
  }

  rabbitmq_user_permissions { "${rabbitmq_user}@${rabbitmq_vhost}":
    configure_permission => '.*',
    read_permission      => '.*',
    write_permission     => '.*',
  }

  package {'ruby-json':
    ensure => present,
  }

  class { 'sensu':
    rabbitmq_password => $rabbitmq_password,
    server            => true,
    dashboard         => true,
    api               => true,
  }

  Class['redis']->Class['sensu']
  Class['rebbitmq']->Class['sensu']
  Package['ruby-json']->Class['sensu']
}
