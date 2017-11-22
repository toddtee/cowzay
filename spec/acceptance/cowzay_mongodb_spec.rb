require 'spec_helper_acceptance'

describe 'cowzay::mongodb' do
  context 'configures firewall' do
    it 'opens port for webserver' do
      pp = <<-EOS
        class {'firewalld':
          package => 'firewalld',
          service_ensure => 'running',
        }

        firewalld_port { 'Open port 27018':  
          ensure   => 'present',  
          zone     => 'public',  
          port     => '27018',  
          protocol => 'tcp',  
        }  
        
        firewalld_port { 'Close port 27017':  
          ensure   => 'absent',  
          zone     => 'public',  
          port     => '27017',  
          protocol => 'tcp',  
        }  
 
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes  => true)
    end

    describe package('firewalld') do
      it {should be_installed }
    end

    describe service('firewalld') do
      it { should be_enabled }
      it { should be_running }
    end
  
    describe command('sudo firewall-cmd --zone=public --list-ports') do
      its(:stdout) {should contain('80/tcp') }
    end

  end

  context 'installs mongodb' do
    it 'deploys apache and website files' do
      pp = <<-EOS
        class { 'apache':                             #install apache and configures basic server 
          default_vhost  => false, 
          service_enable => true,                     #controls if httpd starts on boot 
          service_ensure => true, 
          apache_version => '2.4',                    #ensures 2.4 is installed 
        } 
                                           
        apache::vhost { 'cowzay.com':                 #manages /etc/httpd/cowzay.com configuration 
          servername     => 'cowzay.com', 
          serveraliases  => ['cowzay.com',], 
          port           => '80', 
          docroot        => '/var/www/cowzay', 
          manage_docroot => true, 
          ensure         => 'present',                #ensures the presence of the vhost 
        } 

        file { '/var/www/cowzay':                     #manages the site directory, ie purges it, recreates 
          ensure  => directory, 
          source  => 'puppet:///modules/cowzay', 
          recurse => true, 
          purge   => true, 
          force   => true,                            #purge subdirectries and links 
        } 

      EOS
  
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes  => true)
    end 
    
    describe package('httpd') do
      it { should be_installed.with_version('2.4.6') }
    end

    describe service('httpd') do
      it { should be_running }
      it { should be_enabled }
    end

    describe file('/etc/httpd/conf/httpd.conf') do
      it { should be_file }
    end 

    describe file('/var/www/cowzay') do
      it { should be_directory }
    end  
  end 
end


### Detailed Exit Codes ####
# :catch_failures  => true - expects 0 & 2
# :catch_changes   => true - expects 0
# :expect_failures => true - expects 0,4 & 6
# :expect_changes  => true - expects 2 
