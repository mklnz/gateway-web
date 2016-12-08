class Setting
  include Mongoid::Document
  field :key, type: String
  field :value

  PROXY_MODES = [:blocked_servers, :foreign_servers, :all_servers].freeze

  after_save :send_callback

  def self.get(key)
    setting = Setting.find_by(key: key)
    setting.value unless setting.nil?
  rescue Mongoid::Errors::DocumentNotFound
    nil
  end

  def self.set(key, value)
    setting = Setting.find_or_create_by(key: key)
    return true if value == setting.value

    setting.value = value
    result = setting.save
    result
  end

  def self.delete(key)
    setting = Setting.find_by(key: key)
    setting.destroy
  end

  def self.restore_proxy_mode
    mode = Setting.get('proxy_mode')

    return unless ENV['GATEWAY_DEVICE']
    Gateway::Firewall.instance.setup
    Gateway::Firewall.instance.switch_mode(mode)
  end

  def self.auth_set?
    Setting.get('cns_email').present? && Setting.get('cns_token').present?
  end

  def self.api_update
    MetadataServer.sync_all
    ApiServer.first.sync_ss_servers
  end

  private

  # Callbacks
  def send_callback
    send("#{key}_changed", value) if respond_to?("#{key}_changed", true)
  end

  def active_server_id_changed(value)
    if value.nil?
      Setting.set('proxy_mode', '')
      return
    end
    server = Server.find(value)

    return unless ENV['GATEWAY_DEVICE']
    Gateway::Shadowsocks.instance.save_ss_config(server.ss_config) if server.present?
    Setting.restore_proxy_mode
  end

  def proxy_mode_changed(value)
    Gateway::Firewall.instance.switch_mode(value) if ENV['GATEWAY_DEVICE']
  end
end
