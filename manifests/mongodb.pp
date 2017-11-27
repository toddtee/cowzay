class cowzay::mongodb {

###### MongoDB Firewall Config ##########

 #open default port 27017 in public zone
  firewalld_port { 'Open port 27017 in public zone':
    ensure    => 'present',
    zone      => 'public',
    port      => '27017',
    protocol  => 'tcp',
  }
 
 #disable 27018; sharding not implemented

  firewalld_port { 'Close 27018 in public zone':
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
    manage_package_repo   => false,                #package not managed as we require specific version
    mongod_service_manage => true,
    server_package_name   => 'mongodb-org',
    version               => '3.0.4',
    user                  => 'mongod',
    group                 => 'mongod',
  }

#manage the port and ensure server is present

  class { '::mongodb::server':
    port            => 27017,     
    #auth            => true,                      #issues creating admin users https://tickets.puppetlabs.com/browse/MODULES-534
    #noauth          => false,
    handle_creds   => true,
    store_creds   => true,
    create_admin   => true,
    admin_username => 'admin',
    admin_password => 'password',
    verbose         => true,
    logpath         => '/var/log/mongodb/mongodb.log',
    dbpath          => '/var/lib/mongodb',
  }

  mongodb::db {'mongcow':
    user          => 'mongod',
    password_hash => '7c67ef13bbd4cae106d959320af3f704',  #admin:mongo:admin
    roles         => ['dbAdmin'],
  }

}

