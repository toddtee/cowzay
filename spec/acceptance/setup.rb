if os[:family] == 'redhat' 
  
  $httpd_ver       = '2.4.6'
  $httpd_port      = '80'
  $httpd_conf      = '/etc/httpd/conf/httpd.conf'
  $doc_root        = '/var/www/'
  $vhost           = 'cowzay'
  $apache_package  = 'httpd'
  $apache_service  = 'httpd'
  $expected_content = File.read('files/cowzay/index.html')

  $mongodb_ver     = '3.0.4'
  $mongodb_port    = '27017'
  $mongodb_package = 'mongodb-org-server*'
  $mongodb_service = 'mongod'

  $mysql_ver       = '5.6.*'
  $mysql_port      = '3306'
  $mysql_package   = 'mysql-community-server*'
  $mysql_service   = 'mysqld'

else

end

