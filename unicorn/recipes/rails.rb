unless node[:opsworks][:skip_uninstall_of_other_rails_stack]
  include_recipe "apache2::uninstall"
end

include_recipe "nginx"
include_recipe "unicorn"

# setup Unicorn service per app
node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'rails'
    Chef::Log.debug("Skipping unicorn::rails application #{application} as it is not an Rails app")
    next
  end

  opsworks_deploy_user do
    deploy_data deploy
  end

  opsworks_deploy_dir do
    user deploy[:user]
    group deploy[:group]
    path deploy[:deploy_to]
  end

  template "#{deploy[:deploy_to]}/shared/scripts/unicorn" do
    mode '0755'
    owner deploy[:user]
    group deploy[:group]
    source "unicorn.service.erb"
    variables(:deploy => deploy, :application => application, :platform => node['platform'])
  end

  # NIFTY: Create symlink for Unicorn bootscript.
  link "/etc/init.d/unicorn_#{application}" do
    to "#{deploy[:deploy_to]}/shared/scripts/unicorn"
  end

  service "unicorn_#{application}" do
    start_command "/etc/init.d/unicorn_#{application} start"
    stop_command "/etc/init.d/unicorn_#{application} stop"
    restart_command "/etc/init.d/unicorn_#{application} restart"
    status_command "/etc/init.d/unicorn_#{application} status"
    action :enable
  end

  template "#{deploy[:deploy_to]}/shared/config/unicorn.conf" do
    mode '0644'
    owner deploy[:user]
    group deploy[:group]
    source "unicorn.conf.erb"
    variables(:deploy => deploy, :application => application)
  end
end
