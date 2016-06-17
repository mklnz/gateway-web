require 'json'

class Tunnel
  CONFIG_FILE = '/etc/shadowsocks-libev/config.json'.freeze
  attr_accessor :config

  def initialize
    self.config = JSON.parse(File.read(CONFIG_FILE))
  rescue
    self.config = {}
  end

  def restart
    `service shadowsocks-libev restart`
  end
end
