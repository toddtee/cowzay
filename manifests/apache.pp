class cowzay::apache {
 
####### Apache Firewall Configuration ###########

 #open port 80 to in public zone
  firewalld_port { 'Open port 80': 
    ensure   => 'present', 
    zone     => 'public', 
    port     => '80', 
    protocol => 'tcp', 
  } 

  #disable http service; http will be managed by port alone

  firewalld_service { 'Ensure http on public zone':        
    ensure  => 'absent',
    service => 'http',
    zone    => 'public',
  }
 
####### Apache Configuration #############

  class { 'apache':			#install apache and configures basic server
    default_vhost  => false,
    service_enable => true,		#controls if httpd starts on boot
    service_ensure => true,
    apache_version => '2.4',		#ensures 2.4 is installed
  }
  
  apache::vhost { 'cowzay.com': 	#manages /etc/httpd/cowzay.com configuration
    servername     => 'cowzay.com',
    serveraliases  => ['cowzay.com',],
    port           => '80',
    docroot        => '/var/www/cowzay',
    manage_docroot => true,
    ensure         => 'present',		#ensures the presence of the vhost
  }
  
  file { '/var/www/cowzay':		#manages the site directory, ie purges it, recreates
    ensure  => directory,
    source  => 'puppet:///modules/cowzay/cowzay',
    mode    => '0755',
    recurse => true,
    purge   => true,
    force   => true,			#purge subdirectries and links
  }
 
} 
