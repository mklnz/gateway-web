require 'yaml'
require 'socket'
require_relative 'dns'
require_relative 'firewall'
require_relative 'tunnel'

class Gateway
  CONFIG_DIR = File.expand_path('../../config/', __FILE__)

  attr_accessor :config, :dns, :firewall, :tunnel

  def initialize
    self.config = YAML.load_file(File.join(CONFIG_DIR, 'main.yml'))
    self.dns = DNS.new
    self.firewall = Firewall.new
    self.tunnel = Tunnel.new
  end

  def inclusive_hosts
    YAML.load_file(inclusive_hosts_file) || []
  end

  def inclusive_hosts=(hosts)
    hosts = hosts.map(&:strip).reject(&:empty?)
    File.open(inclusive_hosts_file, 'w+') { |f| f.write(hosts.to_yaml) }
    dns_manager.update_gfwlist
  end

  def stats
    stats = {}
    stats[:local_ip] = IPSocket.getaddress(Socket.gethostname)
    stats[:tunnel_ip] = tunnel.config['server_ip']
    stats
  end

  private

  def inclusive_hosts_file
    File.join(CONFIG_DIR, 'inclusive_hosts.yml')
  end
end
