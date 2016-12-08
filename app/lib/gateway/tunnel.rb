module Gateway
  class Tunnel < Base
    include Singleton

    TUNNEL_SCRIPT_FILE = "#{Dir.home}/tunnel.sh".freeze
    SSH_CONF_DIR = "#{Dir.home}/.ssh".freeze

    def save_tunnel_config(tunnel)
      File.write(
        TUNNEL_SCRIPT_FILE,
        gen_script(tunnel[:host], tunnel[:port], tunnel[:remote_forward_port])
      )
      File.chmod(0o755, TUNNEL_SCRIPT_FILE)
      load_ss_config
      restart
    end

    def restart
      `sudo systemctl restart tunnel.service`
    end

    def gen_script(host, port, remote_forward_port)
      "#!/bin/bash
      /usr/bin/autossh -M 0 -o 'ServerAliveInterval 30' \
      -o 'ServerAliveCountMax 3' -N -f -R #{remote_forward_port}:127.0.0.1:22 \
      tunnel@#{host}:#{port}"
    end

    def save_keys(public_key, private_key)
      public_key_file = "#{SSH_CONF_DIR}/id_rsa.pub"
      private_key_file = "#{SSH_CONF_DIR}/id_rsa"

      File.write(public_key_file, public_key)
      File.write(private_key_file, private_key)
      File.chmod(0o644, public_key_file)
      File.chmod(0o600, private_key_file)
    end
  end
end
