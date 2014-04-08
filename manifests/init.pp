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
class monitoring (
  $checks            = undef,
  $plugins           = undef,
  $rabbitmq_host     = undef,
  $rabbitmq_password = $monitoring::params::rabbitmq_password,
  $rabbitmq_vhost    = $monitoring::params::rabbitmq_vhost,
  $rabbitmq_user     = $monitoring::params::rabbitmq_user,
  $rabbitmq_exchange = $monitoring::params::rabbitmq_exchange,
  $subscriptions     = $monitoring::params::subscriptions
) inherits monitoring::params {

  if $plugins {
    $plugins_real = $plugins
  }
  else {
    $plugins_real = hiera_array('monitoring::plugins', [])
  }

  include ::monitoring::server::install

  class { '::sensu':
    rabbitmq_host     => $rabbitmq_host,
    rabbitmq_password => $rabbitmq_password,
    rabbitmq_vhost    => $rabbitmq_vhost,
    plugins           => $plugins_real,
    subscriptions     => $subscriptions
  }

  $defaults = {
    handlers     => 'default',
    standalone   => true,
  }

  if $checks {
    create_resources(sensu::check, $checks, $defaults)
  }
}
