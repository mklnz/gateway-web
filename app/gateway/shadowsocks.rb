require 'singleton'

class Shadowsocks
  include Singleton

  SS_CONFIG_PATH = '/etc/shadowsocks-libev/config.json'.freeze

  def ss_config
    @ss_config.nil? ? load_ss_config : @ss_config
  end

  def load_ss_config
    @ss_config = JSON.parse(
      File.read(SS_CONFIG_PATH)
    )
  end

  def save_ss_config(ss_config)
    File.write(SS_CONFIG_PATH, ss_config)
    restart
  end

  def restart
    `sudo systemctl restart shadowsocks-libev-redir@config`
  end
end
