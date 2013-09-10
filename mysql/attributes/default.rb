case node[:platform_family]
when "rhel" 
  # NIFTY: RPM infomation
  default[:mysql][:shared_compat_package_name] = "MySQL-shared-compat" 
  default[:mysql][:shared_package_name] = "MySQL-shared" 
  default[:mysql][:devel_package_name] = "MySQL-devel" 
  default[:mysql][:client_package_name] = "MySQL-client" 
  default[:mysql][:server_package_name] = "MySQL-server" 

  default[:mysql][:custom_package_version] = "5.5.33-1" 

  default[:mysql][:shared_compat_package] = "#{node[:mysql][:shared_compat_package_name]}-#{node[:mysql][:custom_package_version]}.el6.x86_64.rpm" 
  default[:mysql][:shared_package] = "#{node[:mysql][:shared_package_name]}-#{node[:mysql][:custom_package_version]}.el6.x86_64.rpm" 
  default[:mysql][:devel_package] = "#{node[:mysql][:devel_package_name]}-#{node[:mysql][:custom_package_version]}.el6.x86_64.rpm" 
  default[:mysql][:client_package] = "#{node[:mysql][:client_package_name]}-#{node[:mysql][:custom_package_version]}.el6.x86_64.rpm" 
  default[:mysql][:server_package] = "#{node[:mysql][:server_package_name]}-#{node[:mysql][:custom_package_version]}.el6.x86_64.rpm" 

  default[:mysql][:package_base_url] = "#{node[:opsworks_commons][:assets_url]}/packages/#{node[:platform]}/#{node[:platform_version]}" 

  default[:mysql][:shared_compat_package_url] = "#{node[:mysql][:package_base_url]}/#{node[:mysql][:shared_compat_package]}" 
  default[:mysql][:shared_package_url] = "#{node[:mysql][:package_base_url]}/#{node[:mysql][:shared_package]}" 
  default[:mysql][:devel_package_url] = "#{node[:mysql][:package_base_url]}/#{node[:mysql][:devel_package]}" 
  default[:mysql][:client_package_url] = "#{node[:mysql][:package_base_url]}/#{node[:mysql][:client_package]}" 
  default[:mysql][:server_package_url] = "#{node[:mysql][:package_base_url]}/#{node[:mysql][:server_package]}" 
end
