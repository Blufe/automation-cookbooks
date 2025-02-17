include_recipe 'opsworks_initial_setup::sysctl'
include_recipe 'opsworks_initial_setup::limits'
include_recipe 'opsworks_initial_setup::bind_mounts'
include_recipe 'opsworks_initial_setup::vol_mount_point'
include_recipe 'opsworks_initial_setup::remove_landscape'
include_recipe 'opsworks_initial_setup::ldconfig'

include_recipe 'opsworks_initial_setup::yum_conf'
include_recipe 'opsworks_initial_setup::tweak_chef_yum_dump'
include_recipe 'opsworks_initial_setup::setup_rhel_repos'

include_recipe 'opsworks_initial_setup::package_procps'
include_recipe 'opsworks_initial_setup::package_ntpd'
include_recipe 'opsworks_initial_setup::package_vim'
include_recipe 'opsworks_initial_setup::package_sqlite'
include_recipe 'opsworks_initial_setup::package_screen'

include_recipe 'opsworks_initial_setup::ufw'
