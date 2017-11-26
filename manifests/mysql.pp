class cowzay::mysql {

#open port 3306 to in public zone 
  firewalld_port { 'Open port 3306 in public zone': 
    ensure    => 'present', 
    zone      => 'public', 
    port      => '3306', 
    protocol  => 'tcp', 
  } 

  service { 'mariadb' :
    ensure => stopped,
  }

 
  $mariadb_pkgs = ['MariaDB-common', 'MariaDB-client', 'MariaDB-server', 'MariaDB-libs', 'boot-program-options', 'galera', 'jemalloc', 'lsof']
  $mariadb_files = ['/etc/systemd/system/mysqld.service', '/etc/systemd/system/mariadb.service']

  package { $mariadb_pkgs:
    ensure => purged,
  }


  file { $mariadb_files :
    ensure => absent,
  }
  
#puppet code for obtaining MySQL 5.6 on CentOS7
#Works in conjunction with hiera; see https://github.com/puppetlabs/puppetlabs-mysql#install-mysql-community-server-on-centos

#  include ::mysql::server

  create_resources(yumrepo, hiera('yumrepo', {}))

  Yumrepo['repo.mysql.com'] -> Anchor['mysql::server::start']
  Yumrepo['repo.mysql.com'] -> Package['mysql_client']

  create_resources(mysql::db, hiera('mysql::server::db', {}))
  
  file { '/usr/lib/systemd/system/mysqld.service' :
    ensure => file,
    source => 'puppet:///modules/cowzay/mysql.service',
  }


#create mysql server, ensure service enabled

  class { '::mysql::server':
    service_enabled         => true,
    root_password           => 'puppet',
    remove_default_accounts => true,
  }  
}

