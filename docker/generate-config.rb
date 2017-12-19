require 'yaml'
require 'erb'

@config = YAML.load(ARGF.read)

data_dir = @config['common']['data_dir']

if @config.has_key?('backblaze-backup')
  backup_config = @config['backblaze-backup']
  backup_config['backup_dir'] = @config['common']['backup_dir']
  backup_config['backup_targets'] = {}
  backup_config['backup_targets'][data_dir] = {}

  exclude = []
  exclude = exclude + backup_config['separate'] if backup_config.has_key?('separate') && backup_config['separate'].is_a?(Array)
  exclude = exclude + backup_config['exclude'] if backup_config.has_key?('exclude') && backup_config['exclude'].is_a?(Array)

  backup_config['backup_targets'][data_dir]['exclude'] = exclude unless exclude.empty?

  if backup_config.has_key?('separate') && backup_config['separate'].is_a?(Array)
    backup_config['separate'].each do |sep|
      backup_config['backup_targets']["#{data_dir}/#{sep}"] = {}
    end
  end
end

def subkey(key, subkey)
  @config[key][subkey] if @config.has_key?(key) && @config[key].is_a?(Hash) && @config[key].has_key?(subkey) && !@config[key][subkey].nil?
end

File.write('/config/cloud.yaml', ERB.new(File.read('/cloud.yaml.erb')).result)
File.write('/config/backup-config.yaml', backup_config.to_yaml) unless backup_config.nil?
File.write('/config/data_dir', data_dir)
File.write('/config/zerotier_network', subkey('zerotier-one', 'network')) unless subkey('zerotier-one', 'network').nil?
File.write('/config/rsync_authorized_keys', subkey('rsync', 'authorized_keys')) unless subkey('rsync', 'authorized_keys').nil?
File.write('/config/virtual_host', subkey('nextcloud', 'virtual_host')) unless subkey('nextcloud', 'virtual_host').nil?
