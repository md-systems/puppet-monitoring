# == Class: monitoring::sensu
#
# Internal helper to install reqired packages for sensu.
#
# === Examples
#
#  Do not use on its own.
#
# === Authors
#
# Christian Haeusler <christian.haeusler@md-systems.ch>
#
# === Copyright
#
# Copyright 2014 MD Systems.
#
class monitoring::sensu::install {
  package {'ruby-json':
    ensure => present,
  }

  package {'sensu-plugin':
    ensure   => present,
    provider => gem,
  }
}
