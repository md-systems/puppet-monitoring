# == Class: monitoring
#
# === Examples
#
#  class { 'monitoring': }
#
# === Authors
#
# Christian Haeusler <christian.haeusler@md-systems.ch>
#
# === Copyright
#
# Copyright 2013 MD Systems.
#
class monitoring::sensu (
  $rabbitmq_password
) {
  class {'redis': }
  class {'rabbitmq':
    delete_guest_user => true,
  }

  rabbitmq_user { 'sensu':
    admin    => true,
    password => $rabbitmq_password,
  }

  rabbitmq_vhost { 'sensu':
    ensure => present,
  }

  rabbitmq_user_permissions { 'sensu@*':
    configure_permission => '.*',
    read_permission      => '.*',
    write_permission     => '.*',
  }
}
