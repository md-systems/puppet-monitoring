# Class: monitoring::params
#
# This class manages monitroring parameters
#
# Parameters:
#
#
class monitoring::params {
  $rabbitmq_password = 'secret'
  $rabbitmq_vhost = '/sensu'
  $rabbitmq_user = 'sensu'
  $rabbitmq_exchange = 'metrics'

  if $::osfamily == 'Debian' {

  } else {
    fail("Class['monitoring::params']: Unsupported osfamily: ${::osfamily}")
  }

  $subscriptions = ['default']

  $graphite_vhost_name = "graphite.${$::fqdn}"
  $graphite_vhost_port = 80
}
