package { 'python-pip':
  ensure => present,
}

package { 'python-dev':
  ensure => present,
  before => Package['txamqp'],
}

package { ' twisted':
  ensure   => '11.1.0',
  provider => pip,
  require  => Package['python-pip'],
}

package { 'txamqp':
  ensure   => present,
  provider => pip,
  require  => Package['python-pip'],
}

package { 'build-essential':
  ensure => present,
}

package { 'ruby-dev':
  ensure => present,
}

include monitoring::server
