# NIFTY: RPM install if platform is CentOS
if node[:platform_family] == 'rhel' and node[:platform] != 'amazon'

  remote_file "/tmp/#{node[:mysql][:shared_compat_package_name]}.rpm" do
    source "#{node[:mysql][:shared_compat_package_url]}" 
    not_if do
      system("rpm -q #{node[:mysql][:shared_compat_package_name]} | grep -q '#{node[:mysql][:shared_compat_package_name]}-#{node[:mysql][:custom_package_version]}'")
    end
  end

  execute "install #{node[:mysql][:shared_compat_package_name]}" do
    command "rpm -i /tmp/#{node[:mysql][:shared_compat_package_name]}.rpm && rm /tmp/#{node[:mysql][:shared_compat_package_name]}.rpm" 
    only_if { ::File.exists?("/tmp/#{node[:mysql][:shared_compat_package_name]}.rpm") }
  end

  remote_file "/tmp/#{node[:mysql][:shared_package_name]}.rpm" do
    source "#{node[:mysql][:shared_package_url]}" 
    not_if do
      system("rpm -q #{node[:mysql][:shared_package_name]} | grep -q '#{node[:mysql][:shared_package_name]}-#{node[:mysql][:custom_package_version]}'")
    end
  end

  execute "install #{node[:mysql][:shared_package_name]}" do
    command "rpm -i /tmp/#{node[:mysql][:shared_package_name]}.rpm && rm /tmp/#{node[:mysql][:shared_package_name]}.rpm" 
    only_if { ::File.exists?("/tmp/#{node[:mysql][:shared_package_name]}.rpm") }
  end

  package "mysql-libs" do
    action  :remove
  end

  remote_file "/tmp/#{node[:mysql][:devel_package_name]}.rpm" do
    source "#{node[:mysql][:devel_package_url]}" 
    not_if do
      system("rpm -q #{node[:mysql][:devel_package_name]} | grep -q '#{node[:mysql][:devel_package_name]}-#{node[:mysql][:custom_package_version]}'")
    end
  end

  execute "install #{node[:mysql][:devel_package_name]}" do
    command "rpm -i /tmp/#{node[:mysql][:devel_package_name]}.rpm && rm /tmp/#{node[:mysql][:devel_package_name]}.rpm" 
    only_if { ::File.exists?("/tmp/#{node[:mysql][:devel_package_name]}.rpm") }
  end

  remote_file "/tmp/#{node[:mysql][:client_package_name]}.rpm" do
    source "#{node[:mysql][:client_package_url]}" 
    not_if do
      system("rpm -q #{node[:mysql][:client_package_name]} | grep -q '#{node[:mysql][:client_package_name]}-#{node[:mysql][:custom_package_version]}'")
    end
  end

  execute "install #{node[:mysql][:client_package_name]}" do
    command "rpm -i /tmp/#{node[:mysql][:client_package_name]}.rpm && rm /tmp/#{node[:mysql][:client_package_name]}.rpm" 
    only_if { ::File.exists?("/tmp/#{node[:mysql][:client_package_name]}.rpm") }
  end

else
  package 'mysql-devel' do
    package_name value_for_platform(
      ['centos','redhat','fedora','amazon'] => {'default' => 'mysql-devel'},
      'ubuntu' => {'default' => 'libmysqlclient-dev'}
    )
    action :install
  end

  package 'mysql-client' do
    package_name value_for_platform(
      ['centos','redhat','fedora','amazon'] => {'default' => 'mysql'},
      'default' => 'mysql-client'
    )
    action :install
  end
end
