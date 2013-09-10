include_recipe 'opsworks_ganglia::client'

def install_and_delete_local_deb_package(deb_file)
  dpkg_package deb_file do
    source deb_file
    only_if { ::File.exists?(deb_file) }
  end
  execute "delete temporary file" do
    command "rm -f #{deb_file}"
  end
end

# NIFTY: RPM install function
def install_and_delete_local_rpm_package(rpm_file)
  rpm_package rpm_file do
    source rpm_file
    only_if { ::File.exists?(rpm_file) }
  end
  execute "delete temporary file" do
    command "rm -f #{rpm_file}" 
  end
end

case node[:platform_family]
when "rhel" 
  if node[:platform] == "amazon" 
    package node[:ganglia][:gmetad_package_name]
    package node[:ganglia][:web_frontend_package_name]
  else
    # NIFTY: RPM install if platform is CentOS
    package 'rrdtool'

    rpm_file = "/tmp/#{node[:ganglia][:gmetad_package_name]}" 
    remote_file rpm_file do
      source node[:ganglia][:gmetad_package_url]
      not_if do
        system("rpm -q #{node[:ganglia][:gmetad_package_name]} | grep -q '#{node[:ganglia][:gmetad_package_name]}-#{node[:ganglia][:custom_package_version]}'")
      end
    end
    install_and_delete_local_rpm_package rpm_file

    node[:ganglia][:web_frontend_dependencies].each do |web_frontend_dependency|
      package web_frontend_dependency
    end

    rpm_file = "/tmp/#{node[:ganglia][:web_frontend_package_name]}" 
    remote_file rpm_file do
      source node[:ganglia][:web_frontend_package_url]
      not_if do
        system("rpm -q #{node[:ganglia][:web_frontend_package_name]} | grep -q '#{node[:ganglia][:web_frontend_package_name]}-#{node[:ganglia][:custom_package_version]}'")
      end
    end

    execute "install #{node[:ganglia][:web_frontend_package_name]}" do
      command "rpm -i #{rpm_file} --relocate /var/www/html/ganglia=/usr/share/ganglia && rm #{rpm_file}" 
      only_if { ::File.exists?(rpm_file) }
    end
  end

when "debian"
  package 'librrd4'

  deb_file = "/tmp/#{node[:ganglia][:gmetad_package_name]}.deb"
  remote_file deb_file do
    source node[:ganglia][:gmetad_package_url]
    not_if do
      `dpkg-query --show gmetad | cut -f 2`.chomp.eql?(node[:ganglia][:custom_package_version])
    end
  end
  install_and_delete_local_deb_package deb_file

  node[:ganglia][:web_frontend_dependencies].each do |web_frontend_dependency|
    package web_frontend_dependency
  end

  deb_file = "/tmp/#{node[:ganglia][:web_frontend_package]}.deb"
  remote_file deb_file do
    source node[:ganglia][:web_frontend_package_url]
    not_if do
      `dpkg-query --show  ganglia-webfrontend | cut -f 2`.chomp.eql?(node[:ganglia][:custom_package_version])
    end
  end
  install_and_delete_local_deb_package deb_file
end

execute "Ensure permission and ownership of web frontend" do
  command "chown -R #{node[:apache][:user]}:#{node[:apache][:group]} #{node[:ganglia][:web][:destdir]}"
end

include_recipe 'opsworks_ganglia::service-gmetad'

service 'gmetad' do
  action :stop
end

include_recipe 'opsworks_ganglia::bind-mount-data'

template '/etc/ganglia/gmetad.conf' do
  source 'gmetad.conf.erb'
  variables :stack_name => node[:opsworks][:stack][:name]
  mode "0644"
end

execute "fix permissions on ganglia rrds directory" do
 command "chown -R #{node[:ganglia][:rrds_user]}:#{node[:ganglia][:user]} #{node[:ganglia][:datadir]}/rrds"
end

include_recipe 'apache2::service'

service 'httpd' do
  case node[:platform]
  when 'centos','redhat','fedora','amazon'
    action :enable
  end
end

service 'gmetad' do
  action [ :enable, :start ]
end
