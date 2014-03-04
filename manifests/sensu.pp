# == Class: monitoring::sensu
#
# Installs a sensu server with rabbitmq and redis all on one host.
#
# === Examples
#
#  class { 'monitoring::sensu':
#    rabbitmq_password => 'sensu',
#  }
#
# === Requirments
#
# On debian systems the packages rub-dev and buidl-essential needs to be present.
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
  $rabbitmq_vhost = '/sensu',
  $rabbitmq_user = 'sensu'
) {
  class {'::redis': }
  class {'::rabbitmq':
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

  class { '::graphite': }

  include ::monitoring::sensu::install

  class { '::sensu':
    rabbitmq_password => $rabbitmq_password,
    rabbitmq_vhost    => $rabbitmq_vhost,
    server            => true,
    dashboard         => true,
    api               => true,
    plugins           => [
      'puppet:///modules/monitoring/files/sensu/plugins/check-procs.rb'
    ],
  }

  Class['::redis']->Class['::sensu']
  Class['::rabbitmq']->Class['::sensu']
  Class['::monitoring::sensu::install']->Class['::sensu']

  sensu::check{ 'cron_check':
    command      => '/etc/sensu/plugins/check-procs.rb -p crond -C 1',
    handlers     => 'default',
    subscribers  => 'default'
  }
}
