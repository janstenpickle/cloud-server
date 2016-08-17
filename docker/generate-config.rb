require 'yaml'
require 'erb'

config = YAML.load(ARGF.read)

backup_config = config['backblaze-backup']
backup_config['backup_dir'] = config['common']['backup_dir']
backup_config['backup_targets'] = {}
backup_config['backup_targets'][config['common']['data_dir']] = {}

exclude = []
exclude = exclude + backup_config['separate'] if backup_config.has_key?('separate') && backup_config['separate'].is_a?(Array)
exclude = exclude + backup_config['exclude'] if backup_config.has_key?('exclude') && backup_config['exclude'].is_a?(Array)

backup_config['backup_targets'][config['common']['data_dir']]['exclude'] = exclude unless exclude.empty?

if backup_config.has_key?('separate') && backup_config['separate'].is_a?(Array)
  backup_config['separate'].each do |sep|
    backup_config['backup_targets']["#{config['common']['data_dir']}/#{sep}"] = {}
  end
end

File.write('/config/cloud.yaml', ERB.new(File.read('/cloud.yaml.erb')).result)
File.write('/config/backup-config.yaml', backup_config.to_yaml)
