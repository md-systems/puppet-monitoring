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
      'puppet:///modules/monitoring/sensu/plugins/check-cpu.rb',
      'puppet:///modules/monitoring/sensu/plugins/check-procs.rb',
      'puppet:///modules/monitoring/sensu/plugins/cpu-metrics.rb'
    ],
  }

  Class['::redis']->Class['::sensu']
  Class['::rabbitmq']->Class['::sensu']
  Class['::monitoring::sensu::install']->Class['::sensu']

  Sensu::Check {
    handlers     => 'default',
    subscribers  => 'default',
    standalone   => false,
  }

  sensu::check{ 'check_cron':
    command      => '/etc/sensu/plugins/check-procs.rb -p crond -C 1',
  }
  sensu::check{ 'check_cpu':
    command      => '/etc/sensu/plugins/check-cpu.rb',
  }
  sensu::check{ 'cpu_metrics':
    command      => '/etc/sensu/plugins/cpu-matrics.rb',
    type         => 'metric',
  }
}
