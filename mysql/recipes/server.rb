require 'resolv'

include_recipe 'mysql::client'
include_recipe 'mysql::prepare'

# NIFTY: RPM install if platform is CentOS
if node[:platform_family] == 'rhel' and node[:platform] != 'amazon'
  remote_file "/tmp/#{node[:mysql][:server_package_name]}.rpm" do
    source "#{node[:mysql][:server_package_url]}" 
    not_if do
      system("rpm -q #{node[:mysql][:server_package_name]} | grep -q '#{node[:mysql][:server_package_name]}-#{node[:mysql][:custom_package_version]}'")
    end
  end

  execute "install #{node[:mysql][:server_package_name]}" do
    command "rpm -i /tmp/#{node[:mysql][:server_package_name]}.rpm && rm /tmp/#{node[:mysql][:server_package_name]}.rpm" 
    only_if { ::File.exists?("/tmp/#{node[:mysql][:server_package_name]}.rpm") }
  end

  directory "/var/run/mysqld" do
    owner "mysql" 
    group "mysql" 
    action :create
  end
else
  package 'mysql-server'
end

if platform?('ubuntu') && node[:platform_version].to_f < 10.04
  remote_file '/tmp/mysql_init.patch' do
    source 'mysql_init.patch'
  end

  execute 'Fix MySQL init.d script to sleep longer - needed for instances with more RAM' do
    cwd '/etc/init.d'
    command 'patch -p0 mysql < /tmp/mysql_init.patch'
    action :run
    only_if do
      File.read('/etc/init.d/mysql').match(/sleep 1/)
    end
  end
end

if platform?('debian','ubuntu')
  include_recipe 'mysql::apparmor'
end

include_recipe 'mysql::service'

service 'mysql' do
  action :enable
end

service 'mysql' do
  action :stop
end

include_recipe 'mysql::ebs'
include_recipe 'mysql::config'

service 'mysql' do
  action :start
end

if platform?('centos','redhat','fedora','amazon')
  execute 'assign root password' do
    command "/usr/bin/mysqladmin -u root password \"#{node[:mysql][:server_root_password]}\""
    action :run
    only_if "/usr/bin/mysql -u root -e 'show databases;'"
  end
end
