class Setting
  include Mongoid::Document
  field :key, type: String
  field :value

  PROXY_MODES = [:blocked_servers, :foreign_servers, :all_servers].freeze

  def self.get(key)
    setting = Setting.find_by(key: key)
    setting.value unless setting.nil?
  rescue Mongoid::Errors::DocumentNotFound
    nil
  end

  def self.set(key, value)
    setting = Setting.find_or_create_by(key: key)
    setting.value = value
    result = setting.save

    if setting.respond_to?("#{key}_changed", true)
      setting.send("#{key}_changed", value)
    end

    result
  end

  def self.bootstrap
    # Load defaults
    defaults = YAML.load_file("#{Rails.root}/config/gateway_defaults.yml")
                   .with_indifferent_access

    defaults.each do |k, v|
      Setting.set(k, v) if Setting.get(k).nil?
    end
  end

  def self.restore_proxy_mode
    mode = Setting.get('proxy_mode')

    return unless ENV['GATEWAY_DEVICE']
    Gateway::Firewall.instance.setup
    Gateway::Firewall.instance.switch_mode(mode)
  end

  private

  # Callback
  def active_server_id_changed(value)
    server = Server.find(value)

    return unless ENV['GATEWAY_DEVICE']
    Gateway::Firewall.instance.set_direct
    Gateway::Shadowsocks.instance.save_ss_config(server.ss_config)
    Setting.restore_proxy_mode
  end

  def proxy_mode_changed(value)
    Gateway::Firewall.instance.switch_mode(value) if ENV['GATEWAY_DEVICE']
  end
end
