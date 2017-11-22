require 'beaker-rspec'
require 'beaker/puppet_install_helper'
 
#run_puppet_install_helper

#Install Puppet on all hosts
install_puppet_agent_on(hosts, options)


RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  
  # Readable test descriptions
  c.formatter = :documentation  

  # Configure all nodes in nodeset
  c.before :suite do
    hosts.each do |host|
      copy_module_to(host, :source => proj_root, :module_name => 'cowzay')
      scp_to hosts, File.join(proj_root, 'spec/fixtures/hieradata/common.yaml'), '/etc/puppetlabs/code/environments/production/hieradata/common.yaml'

#      on host, puppet('module install puppetlabs-stdlib'), {:acceptable_exit_codes => [0]} 
      on host, puppet('module install crayfishx-firewalld'), {:acceptable_exit_codes => [0]} 
      on host, puppet('module install puppetlabs-apache'),{:acceptable_exit_codes => [0]} 
      on host, puppet('module install puppet-mongodb'),{:acceptable_exit_codes => [0]} 
      on host, puppet('module install puppetlabs-mysql'),{:acceptable_exit_codes => [0]} 
    end

    #dependencies installed to provide mongod.service
    #hosts.each do |host|
    #  shell("yum -y install cyrus-sasl cyrus-sasl-gssapi cyrus-sasl-plain krb5-libs libcurl libpcap lm_sensors-libs net-snmp net-snmp-agent-libs openldap openssl rpm-libs tcp_wrappers-libs")
    #end

  end
      #if os-specific dependences are required for the test; use this block 
      #if fact('osfamily') == '<INSERT-OS-FAMILY-HERE!!!>'
      #  on host,puppet('module', 'install','<INSERT-MODULE-HERE!!!>'), { :acceptable_exit_codes => [0,1] }
      #end
     
end
