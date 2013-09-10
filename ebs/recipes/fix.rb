# NIFTY: Get kernel number of fix object.
rules = BlockDevice.fix_list(node[:ebs])

unless rules.empty?
  # NIFTY: Create udev rule file.
  template 'create udev rule' do
    path '/etc/udev/rules.d/10-automation.rules'
    source 'udev.rules.erb'
    owner 'root'
    group 'root'
    variables({
      :scsi_devices => rules
    })
  end

  # NIFTY: udev reload.
  script "reload udev rules" do
    user "root" 
    interpreter "bash" 
    code <<-EOH
      udevadm control --reload-rules
      udevadm trigger
    EOH
  end
end
