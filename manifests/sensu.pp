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
  $rabbitmq_password = 'secret',
  $rabbitmq_vhost = '/sensu',
  $rabbitmq_user = 'sensu',
  $rabbitmq_exchange = 'metrics'
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

  class { '::graphite':
    gr_amqp_enable              => true,
    gr_amqp_vhost               => $rabbitmq_vhost,
    gr_amqp_user                => $rabbitmq_user,
    gr_amqp_password            => $rabbitmq_password,
    gr_amqp_exchange            => $rabbitmq_exchange,
    gr_amqp_metric_name_in_body => true,
  }

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

  sensu::handler { 'graphite':
    type     => 'amqp',
    exchange => {
      'type'    => 'topic',
      'name'    => $rabbitmq_exchange,
      'durable' => true
    },
  }

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
  sensu::check { 'cpu_metrics':
    command  => '/etc/sensu/plugins/cpu-metrics.rb',
    type     => 'metric',
    handlers => ['graphite'],
    interval => 10,
  }
}
