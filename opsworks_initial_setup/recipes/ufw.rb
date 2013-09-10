# NIFTY: disable ufw on Ubuntu 12.04 64bit Plai
if %w(ubuntu debian).include?(node[:platform])
  execute 'disable ufw' do
    command 'ufw disable'
    only_if 'ufw status | grep "^Status: active"'
  end
end
