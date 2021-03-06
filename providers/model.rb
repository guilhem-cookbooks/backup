# Support whyrun
def whyrun_supported?
  true
end

action :create do
  cron_options = new_resource.cron_options || {}

  cron cron_name do
    command cron_options[:command] ||
      "backup perform --trigger #{new_resource.name} --config-file #{node['backup']['config_path']}/config.rb --log-path=#{node['backup']['log_path']} > /dev/null"

    mailto cron_options[:mailto] if cron_options.key?(:mailto)
    path cron_options[:path] if cron_options.key?(:path)
    shell cron_options[:shell] if cron_options.key?(:shell)
    user cron_options[:user] || node['backup']['user']

    minute new_resource.schedule[:minute] || '*'
    hour new_resource.schedule[:hour] || '*'
    day new_resource.schedule[:day] || '*'
    month new_resource.schedule[:month] || '*'
    weekday new_resource.schedule[:weekday] || '*'
  end

  template "Model file for #{new_resource.name}" do
    path model_path
    source model.erb
    owner node['backup']['user']
    group node['backup']['group']
    mode '0600'
  end
end

action :delete do
  cron cron_name do
    action :delete
  end

  template "Model file for #{new_resource.name}" do
    path model_path
    action :delete
  end
end

private

def cron_name
  "#{new_resource.name}_backup"
end

def model_path
  ::File.join(node['backup']['model_path'], "#{new_resource.name}.rb")
end
