class cowzay::mongodb {

###### MongoDB Firewall Config ##########

 #open port 27018 to in public zone
  firewalld_port { 'Open port 27018 in public zone':
    ensure    => 'present',
    zone      => 'public',
    port      => '27017',
    protocol  => 'tcp',
  }
 
 #disable 27017; puppet didn't like the default mongodb port, want to disable until we know why 

  firewalld_port { 'Close 27017 in public zone':
    ensure    => 'absent',
    zone      => 'public',
    port      => '27018' , 
    protocol  => 'tcp',
 }

############ mongodb config ##############

  file { '/etc/yum.repos.d/mongodb-org-3.0.repo':
    ensure => file,
    source => 'puppet:///modules/cowzay/mongodb-org-3.0.repo',
  }

############ Mongo Dependencies ##############

  $mongoDependencies = ['cyrus-sasl', 'cyrus-sasl-gssapi', 'cyrus-sasl-plain', 'krb5-libs', 'libcurl', 'libpcap', 'lm_sensors-libs', 'net-snmp', 'net-snmp-agent-libs', 'openldap', 'openssl', 'rpm-libs', 'tcp_wrappers-libs']

  package { $mongoDependencies: 
    ensure => 'installed',
  }

#install mongodb with version 3.0

  class { '::mongodb::globals':
    manage_package_repo   => false, 
    mongod_service_manage => true,
    server_package_name   => 'mongodb-org',
    version               => '3.0.4',
    user                  => 'mongod',
    group                 => 'mongod',
  }

#manage the port and ensure server is present

  class { '::mongodb::server':
    port    => 27017,                   #default port did not work; utilised shardsrv port instead
    verbose => true,
    #logpath => '/var/log/mongodb/mongodb.log',
    #dbpath => '/var/lib/mongodb',
    auth => true,                      #issues creating users https://tickets.puppetlabs.com/browse/MODULES-534
  }

  #mongodb_database { 'cowzaydb':
  #  ensure => present,
  #}  
  
  #mongodb_user { tester:
  #  username => 'tester',
  #  ensure => present,
  #  password_hash => '768747907b90c39ab6f16fcb3320897a',
  #  database => cowzaydb,
  #  roles => ['dbadmin'],
  #  tries => 3,
  #  require => Class['mongodb::server'],

  #} 
  #service { 'mongod' :
  #  ensure => 'running',
  #  enable => true,
  #}

}

