require 'json'

class Firewall
  def setup
    `ipset -N gfwlist iphash`
    add_dns_ipset
  end

  def clean
    set_direct
    flush_ipset
    `ipset destroy gfwlist`
  end

  def flush_ipset
    `ipset flush gfwlist`
    add_dns_ipset
  end

  def set_global
    set_direct
    config = JSON.parse(File.read('/etc/shadowsocks-libev/config.json'))
    server = config['server']
    port = config['local_port']
    `iptables -t nat -N SHADOWSOCKS`
    `iptables -t nat -A SHADOWSOCKS -d #{server} -j RETURN`
    `iptables -t nat -A SHADOWSOCKS -d 0.0.0.0/8 -j RETURN`
    `iptables -t nat -A SHADOWSOCKS -d 10.0.0.0/8 -j RETURN`
    `iptables -t nat -A SHADOWSOCKS -d 127.0.0.0/8 -j RETURN`
    `iptables -t nat -A SHADOWSOCKS -d 169.254.0.0/16 -j RETURN`
    `iptables -t nat -A SHADOWSOCKS -d 172.16.0.0/12 -j RETURN`
    `iptables -t nat -A SHADOWSOCKS -d 192.168.0.0/16 -j RETURN`
    `iptables -t nat -A SHADOWSOCKS -d 224.0.0.0/4 -j RETURN`
    `iptables -t nat -A SHADOWSOCKS -d 240.0.0.0/4 -j RETURN`
    `iptables -t nat -A SHADOWSOCKS -p tcp -j REDIRECT --to-port #{port}`
    `iptables -t nat -A OUTPUT -p tcp -j SHADOWSOCKS`
    `iptables -t nat -A PREROUTING -p tcp -j SHADOWSOCKS`
  end

  def set_dynamic
    set_direct
    `iptables -t nat -N SHADOWSOCKS`
    `iptables -t nat -A SHADOWSOCKS -d #{server} -j RETURN`
    `iptables -t nat -A SHADOWSOCKS -p tcp -m set --match-set gfwlist dst -j REDIRECT --to-port 1080`
    `iptables -t nat -A OUTPUT -p tcp -j SHADOWSOCKS`
    `iptables -t nat -A PREROUTING -p tcp -j SHADOWSOCKS`
  end

  def set_direct
    `iptables -F`
    `iptables -X`
    `iptables -t nat -F`
    `iptables -t nat -X`
  end

  private

  def add_dns_ipset
    `ipset add gfwlist 8.8.8.8`
    `ipset add gfwlist 8.8.4.4`
  end
end
