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
  $companies = [],
  $locations = []
) {
  $companies.foreach {|$company| File <<| tag == "munin-node-${company}" |>> }
  $locations.foreach {|$location| File <<| tag == "munin-node-${location}" |>> }
  $companies.foreach {|$company| $locations.foreach {|$location| File <<| tag == "munin-node-${company}-${location}" |>> }}
}
