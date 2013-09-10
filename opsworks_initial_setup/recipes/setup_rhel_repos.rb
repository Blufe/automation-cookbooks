if node[:platform] == 'amazon'
  # We only have to run 'yum-config-manager --quiet --enable epel' in order
  # to get EPEL working.
  execute 'yum-config-manager --quiet --enable epel' do
    not_if "yum-config-manager epel | grep 'enabled = True'"
  end
else
  # NIFTY: install epel repository on CentOS 6.3 64bit Plain
  if node[:platform_family] == 'rhel'
    include_recipe 'yum::epel'
  end
end
