class DNS
  def update_gfwlist
    `#{gfwlist2dnsmasq} -c #{g2d_config} -e #{g2d_extras} -o #{g2d_outfile}`
    dnsmasq_restart
  end

  def dnsmasq_restart
    `service dnsmasq restart`
  end

  private

  def gfwlist2dnsmasq
    File.expand_path('../../bin/gfwlist2dnsmasq', __FILE__)
  end

  def g2d_config
    File.expand_path('../../config/gfwlist2dnsmasq.yml', __FILE__)
  end

  def g2d_extras
    File.expand_path('../../config/inclusive_hosts.yml', __FILE__)
  end

  def g2d_outfile
    File.expand_path('../../dnsmasq.d/gfwlist.conf', __FILE__)
  end
end
