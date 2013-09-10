define :opsworks_nodejs do
  deploy = params[:deploy_data]
  application = params[:app]

  service 'monit' do
    action :nothing
  end

  node[:dependencies][:npms].each do |npm, version|
    execute "/usr/local/bin/npm install #{npm}" do
      cwd "#{deploy[:deploy_to]}/current"
    end
  end

  template "#{deploy[:deploy_to]}/shared/config/automation.js" do
    cookbook 'opsworks_nodejs'
    source 'opsworks.js.erb'
    mode '0660'
    owner deploy[:user]
    group deploy[:group]
    variables(:database => deploy[:database], :memcached => deploy[:memcached], :layers => node[:opsworks][:layers])
  end

  #NIFTY : Create SSL Files for Node.js
  directory "#{deploy[:deploy_to]}/shared/ssl" do
    user deploy[:user]
    group deploy[:group]
    only_if do
      deploy[:ssl_support]
    end
  end

  file "#{deploy[:deploy_to]}/shared/ssl/#{application}.crt" do
    mode '0600'
    content deploy[:ssl_certificate]
    owner deploy[:user]
    group deploy[:group]
    notifies :restart, "service[monit]"
    only_if do
      deploy[:ssl_support]
    end
  end

  file "#{deploy[:deploy_to]}/shared/ssl/#{application}.key" do
    mode '0600'
    content deploy[:ssl_certificate_key]
    owner deploy[:user]
    group deploy[:group]
    notifies :restart, "service[monit]"
    only_if do
      deploy[:ssl_support]
    end
  end

  file "#{deploy[:deploy_to]}/shared/ssl/#{application}.ca" do
    mode '0600'
    content deploy[:ssl_certificate_ca]
    owner deploy[:user]
    group deploy[:group]
    notifies :restart, "service[monit]"
    only_if do
      deploy[:ssl_support] && deploy[:ssl_certificate_ca]
    end
  end

  link "#{deploy[:deploy_to]}/current/ssl" do
    to "#{deploy[:deploy_to]}/shared/ssl"
    only_if do
      deploy[:ssl_support]
    end
  end

  template "#{node.default[:monit][:conf_dir]}/node_web_app-#{application}.monitrc" do
    source 'node_web_app.monitrc.erb'
    cookbook 'opsworks_nodejs'
    owner 'root'
    group 'root'
    mode '0644'
    variables(
      :deploy => deploy,
      :application_name => application,
      :monitored_script => "#{deploy[:deploy_to]}/current/server.js"
    )
    notifies :restart, "service[monit]", :immediately
  end
end
