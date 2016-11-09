require 'json'

class Firewall
  attr_accessor :config

  def initialize
    load_config
  end

  def load_config
    self.config = JSON.parse(File.read('/etc/shadowsocks-libev/config.json'))
  end

  def setup
    `sudo ipset -N gfwlist iphash`
    add_dns_ipset
  end

  def clean
    set_direct
    flush_ipset
    `sudo ipset destroy gfwlist`
  end

  def flush_ipset
    `sudo ipset flush gfwlist`
    add_dns_ipset
  end

  def set_global
    set_direct
    `sudo iptables -t nat -N SHADOWSOCKS`
    `sudo iptables -t nat -A SHADOWSOCKS -d #{config['server']} -j RETURN`
    `sudo iptables -t nat -A SHADOWSOCKS -d 0.0.0.0/8 -j RETURN`
    `sudo iptables -t nat -A SHADOWSOCKS -d 10.0.0.0/8 -j RETURN`
    `sudo iptables -t nat -A SHADOWSOCKS -d 127.0.0.0/8 -j RETURN`
    `sudo iptables -t nat -A SHADOWSOCKS -d 169.254.0.0/16 -j RETURN`
    `sudo iptables -t nat -A SHADOWSOCKS -d 172.16.0.0/12 -j RETURN`
    `sudo iptables -t nat -A SHADOWSOCKS -d 192.168.0.0/16 -j RETURN`
    `sudo iptables -t nat -A SHADOWSOCKS -d 224.0.0.0/4 -j RETURN`
    `sudo iptables -t nat -A SHADOWSOCKS -d 240.0.0.0/4 -j RETURN`
    `sudo iptables -t nat -A SHADOWSOCKS -p tcp -j REDIRECT --to-port #{config['local_port']}`
    `sudo iptables -t nat -A OUTPUT -p tcp -j SHADOWSOCKS`
    `sudo iptables -t nat -A PREROUTING -p tcp -j SHADOWSOCKS`
  end

  def set_dynamic
    set_direct
    `sudo iptables -t nat -N SHADOWSOCKS`
    `sudo iptables -t nat -A SHADOWSOCKS -d #{config['server']} -j RETURN`
    `sudo iptables -t nat -A SHADOWSOCKS -p tcp -m set --match-set gfwlist dst -j REDIRECT --to-port #{config['local_port']}`
    `sudo iptables -t nat -A OUTPUT -p tcp -j SHADOWSOCKS`
    `sudo iptables -t nat -A PREROUTING -p tcp -j SHADOWSOCKS`
  end

  def set_direct
    `sudo iptables -F`
    `sudo iptables -X`
    `sudo iptables -t nat -F`
    `sudo iptables -t nat -X`
  end

  private

  def add_dns_ipset
    `sudo ipset add gfwlist 8.8.8.8`
    `sudo ipset add gfwlist 8.8.4.4`
  end
end
