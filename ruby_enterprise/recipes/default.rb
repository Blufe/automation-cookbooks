case node[:platform]
when "debian","ubuntu"
  arch = RUBY_PLATFORM.match(/64/) ? 'amd64' : 'i386'

  remote_file File.join('/tmp', File.basename(node[:ruby_enterprise][:url][arch])) do
    source node[:ruby_enterprise][:url][arch]
    not_if { ::File.exists?(File.join('/tmp', File.basename(node[:ruby_enterprise][:url][arch]))) }
  end

  package "ruby1.9" do
    action :remove
    ignore_failure true
  end

  # NIFTY: Install dependencies package.
  %w(libyaml-0-2 libyaml-dev zlib1g-dev libssl-dev libreadline6-dev).each do |pkg|
    package pkg do
      action :install
      only_if do
        ::File.exists?("/tmp/#{File.basename(node[:ruby_enterprise][:url][arch])}")
      end
    end
  end

  execute "Install Ruby Enterprise Edition" do
    cwd "/tmp"
    command "dpkg -i /tmp/#{File.basename(node[:ruby_enterprise][:url][arch])} && (/usr/local/bin/gem uninstall -a bundler || echo '1')"

    not_if do
      ::File.exists?("/usr/local/bin/ruby") &&
      system("/usr/local/bin/ruby -v | grep -q '#{node[:ruby_enterprise][:version]}$'")
    end
  end

  if node[:platform].eql?('ubuntu') && ['12.04'].include?("#{node[:platform_version]}")
    package 'libssl0.9.8'
  end
when 'centos','redhat','fedora','amazon'
  arch = node[:kernel][:machine]
  remote_file File.join('/tmp', File.basename(node[:ruby_enterprise][:url][arch])) do
    source node[:ruby_enterprise][:url][arch]
    not_if { ::File.exists?(File.join('/tmp', File.basename(node[:ruby_enterprise][:url][arch]))) }
  end

  package "ruby19" do
    action :remove
  end

  # NIFTY: Install dependencies package.
  %w(libyaml libyaml-devel readline-devel ncurses-devel gdbm-devel tcl-devel openssl-devel db4-devel libffi-devel
    openssl098e compat-db43 compat-readline5 compat-libtermcap).each do |pkg|
    package pkg do
      action :install
      only_if do
        ::File.exists?(File.join('/tmp', File.basename(node[:ruby_enterprise][:url][arch])))
      end
    end
  end

  rpm_package 'ruby-enterprise' do
    source File.join('/tmp', File.basename(node[:ruby_enterprise][:url][arch]))
  end
end

# NIFTY: Execute ldconfig.
case node[:platform]
when 'centos','redhat','fedora','amazon','debian','ubuntu'
  execute 'Configure dynamic linker run-time bindings' do
    command 'ldconfig'
  end
end

template "/etc/environment" do
  source "environment.erb"
  mode "0644"
  owner "root"
  group "root"
end

template "/usr/local/bin/ruby_gc_wrapper.sh" do
  source "ruby_gc_wrapper.sh.erb"
  mode "0755"
  owner "root"
  group "root"
end

include_recipe 'opsworks_rubygems'
include_recipe 'opsworks_bundler'
