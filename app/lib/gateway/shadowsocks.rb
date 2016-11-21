module Gateway
  class Shadowsocks < Base
    include Singleton

    SS_CONFIG_PATH = if ENV['GATEWAY_DEVICE']
      '/etc/shadowsocks-libev/config.json'
    else
      File.expand_path('../../../shared/shadowsocks.json', __FILE__)
    end.freeze

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
      load_ss_config
      restart
    end

    def restart
      `sudo systemctl restart shadowsocks-libev-redir@config`
    end
  end
end
