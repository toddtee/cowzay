class cowzay {

  class {'firewalld':
    package => 'firewalld',
    service_ensure => 'running',
  } 

  include cowzay::apache 

  include cowzay::mongodb

  include cowzay::mysql

}
