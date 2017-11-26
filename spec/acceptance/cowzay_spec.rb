require 'spec_helper_acceptance'
require_relative './setup.rb'

describe 'cowzay' do

  context 'when deployed' do
    it 'installs the infrastructure and apps for cowzay' do
      pp = <<-EOS
      include cowzay 
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :expect_changes  => true)
    end

 ########################################### System Checks ###########################################

    describe package('firewalld') do
      it {should be_installed }
    end

    describe service('firewalld') do
      it { should be_enabled }
      it { should be_running }
    end
   
 ########################################### Apache Checks ###########################################

    describe package("#{$apache_package}") do
      it { should be_installed.with_version("#{$httpd_ver}") }
    end

    describe service("#{$apache_service}") do
      it { should be_enabled }
      it { should be_running }
    end
    
    describe command('sudo firewall-cmd --zone=public --list-ports') do
      its(:stdout) {should contain("#{$httpd_port}/tcp") }
    end

    describe file("#{$httpd_conf}") do
      it { should be_file }
    end 

    describe file("#{$doc_root}"'/cowzay') do
      it { should be_directory }
      it { should be_mode 755 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
    end  
    
    describe file("#{$doc_root}""#{$vhost}"'/index.html') do
      it { should be_file }
      its (:content) {should eq "#{$expected_content}" } 
    end 

    describe file('/etc/httpd/conf.d/25-'"#{$vhost}"'.com.conf') do
      it { is_expected.to contain '<VirtualHost *:80>' }
    end
 
 ########################################### Mongodb Checks ###########################################

    describe command('rpm -qa | grep '"#{$mongodb_package}") do   #shell cmd is more precise
      its(:stdout) {should contain("#{$mongodb_ver}") }
    end
    
    describe service("#{$mongodb_service}") do
      it { should be_enabled }
      it { should be_running }
    end
    
    describe command('sudo firewall-cmd --zone=public --list-ports') do
      its(:stdout) {should contain("#{$mongodb_port}/tcp") }
    end

  
 ########################################### MySQL Checks ###########################################

    describe command('rpm -qa | grep '"#{$mysql_package}") do   #shell cmd is more precise
      its(:stdout) {should contain("#{$mysql_ver}") }
    end

    describe service("#{$mysql_service}") do
      it { should be_enabled }
      it { should be_running }
    end
    
    describe command('sudo firewall-cmd --zone=public --list-ports') do
      its(:stdout) {should contain("#{$mysql_port}/tcp") }
    end

    describe 'MySQL Configurations' do 
      context mysql_config('datadir') do
        its(:value) { should eq '/var/lib/mysql/'}
      end
      context mysql_config('socket') do
        its(:value) { should eq '/var/lib/mysql/mysql.sock' }
      end
    end

    describe command('mysql --user "root" --execute "SHOW DATABASES LIKE '"'""#{$mysql_db}""'"';" | grep '"#{$mysql_db}") do   
      its(:stdout) {should contain("#{$mysql_db}") }
    end

  end 
end


### Detailed Exit Codes ####
# :catch_failures  => true - expects 0 & 2
# :catch_changes   => true - expects 0
# :expect_failures => true - expects 0,4 & 6
# :expect_changes  => true - expects 2 
