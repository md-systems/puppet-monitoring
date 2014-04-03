package { 'build-essential':
  ensure => present,
}

package { 'ruby-dev':
  ensure => present,
  require  => Package['build-essential'],
}

node 'monitoring.example.com' {

  package { 'python-pip':
    ensure => present,
    require  => Package['python-dev'],
  }

  package { 'python-dev':
    ensure => present,
    require  => Package['build-essential'],
  }

  package { 'twisted':
    ensure   => '11.1.0',
    provider => pip,
    require  => Package['python-pip'],
  }

  package { 'txamqp':
    ensure   => present,
    provider => pip,
    require  => Package['python-pip'],
  }

  class { monitoring::server:
    plugins => [
      'puppet:///modules/monitoring/sensu/plugins/check-cpu.rb',
      'puppet:///modules/monitoring/sensu/plugins/check-procs.rb',
      'puppet:///modules/monitoring/sensu/plugins/cpu-metrics.rb'
    ],
    checks => {
      check_cron => {
        command => '/etc/sensu/plugins/check-procs.rb -p crond -C 1'
      },
      check_cpu => {
        command => '/etc/sensu/plugins/check-cpu.rb'
      },
      cpu_metrics => {
        command => '/etc/sensu/plugins/cpu-metrics.rb',
        type => 'metric',
        handlers => ['graphite'],
        interval => 10
      }
    }
  }
}

node 'client.example.com' {
  class { monitoring:
    rabbitmq_host => '10.35.107.132',
    plugins => [
      'puppet:///modules/monitoring/sensu/plugins/check-cpu.rb',
      'puppet:///modules/monitoring/sensu/plugins/check-procs.rb',
      'puppet:///modules/monitoring/sensu/plugins/cpu-metrics.rb'
    ],
  }
}
