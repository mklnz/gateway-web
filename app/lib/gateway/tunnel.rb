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

      save_ssh_keys(tunnel[:public_key], tunnel[:private_key])
      save_known_host("#{tunnel[:host]}:#{tunnel[:port]}", tunnel[:host_key])
      restart
    end

    def restart
      `sudo systemctl daemon-reload`
      `sudo systemctl enable tunnel.service`
      `sudo systemctl restart tunnel.service`
    end

    def gen_script(host, port, remote_forward_port)
      "#!/bin/bash
AUTOSSH_PIDFILE=~/tunnel.pid /usr/bin/autossh -M 0 -o 'ServerAliveInterval 30' \
-o 'ServerAliveCountMax 3' -N -f -R #{remote_forward_port}:127.0.0.1:22 \
tunnel@#{host} -p #{port}"
    end

    def save_ssh_keys(public_key, private_key)
      public_key_file = "#{SSH_CONF_DIR}/id_rsa.pub"
      private_key_file = "#{SSH_CONF_DIR}/id_rsa"

      File.write(public_key_file, public_key)
      File.write(private_key_file, private_key)
      File.chmod(0o644, public_key_file)
      File.chmod(0o600, private_key_file)
    end

    def save_known_host(server, known_host_key)
      known_hosts_file = "#{SSH_CONF_DIR}/known_hosts"
      `ssh-keygen -R #{server}`
      open(known_hosts_file, 'a+') do |f|
        f.puts known_host_key
      end
    end
  end
end
