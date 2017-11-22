require 'spec_helper_acceptance'

describe 'cowzay' do

  context 'when deployed' do
    it 'installs the infrastructure and apps for cowzay' do
      pp = <<-EOS
      include cowzay 
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
    
    describe service('mongod') do
      it { should be_enabled }
      it { should be_running }
    end
  
    describe command('sudo firewall-cmd --zone=public --list-ports') do
      its(:stdout) {should contain('80/tcp') }
    end

    
    describe package('httpd') do
      it { should be_installed.with_version('2.4.6') }
    end

    describe service('httpd') do
      it { should be_running }
      it { should be_enabled }
    end
    
    describe service('mysqld') do
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
