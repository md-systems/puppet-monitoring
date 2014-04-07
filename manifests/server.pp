# == Class: monitoring::server
#
# Installs a sensu server with rabbitmq and redis all on one host.
#
# === Examples
#
#  class { 'monitoring::server':
#    rabbitmq_password => 'sensu',
#  }
#
# === Requirments
#
# On debian systems the packages rub-dev and buidl-essential needs to be
# present.
#
# === Authors
#
# Christian Haeusler <christian.haeusler@md-systems.ch>
#
# === Copyright
#
# Copyright 2014 MD Systems.
#
class monitoring::server (
  $checks            = undef,
  $plugins           = undef,
  $subscriptions     = $monitoring::params::subscriptions,
  $rabbitmq_password = $monitoring::params::rabbitmq_password,
  $rabbitmq_vhost    = $monitoring::params::rabbitmq_vhost,
  $rabbitmq_user     = $monitoring::params::rabbitmq_user,
  $rabbitmq_exchange = $monitoring::params::rabbitmq_exchange
) inherits monitoring::params {
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

  include ::monitoring::server::install


  if $plugins {
     $plugins_real = $plugins
  }
  else {
    $plugins_real = hiera_hash('monitoring::plugins', [])
  }

  class { '::sensu':
    rabbitmq_password => $rabbitmq_password,
    rabbitmq_vhost    => $rabbitmq_vhost,
    server            => true,
    dashboard         => true,
    api               => true,
    plugins           => $plugins_real,
    subscriptions     => $subscriptions
  }

  Class['::redis']->Class['::sensu']
  Class['::rabbitmq']->Class['::sensu']
  Class['::monitoring::server::install']->Class['::sensu']

  sensu::handler { 'graphite':
    type     => 'amqp',
    exchange => {
      'type'    => 'topic',
      'name'    => $rabbitmq_exchange,
      'durable' => true
    },
    mutator => [
      'only_check_output',
    ],
  }

  $defaults = {
    handlers     => 'default',
    subscribers  => 'default',
    standalone   => false,
  }

  if $checks {
    create_resources(sensu::check, $checks, $defaults)
  }
  else {
    $hiera_checks = hiera_hash('monitoring::checks', undef)
    if $hiera_checks {
      create_resources(sensu::check, $hiera_checks, $defaults)
    }
  }
}
