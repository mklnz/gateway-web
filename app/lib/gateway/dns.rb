module Gateway
  class DNS < Base
    include Singleton

    CHINA_DOMAINS_FILE = File.join(Rails.root, 'shared', 'dnsmasq.d',
                                   'accelerated-domains.china.conf').freeze
    CHINA_DOMAINS_URL = 'https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/accelerated-domains.china.conf'.freeze

    def update_gfwlist
      `#{gfwlist2dnsmasq} -c #{g2d_config} -e #{g2d_extras} -o #{g2d_outfile}`
      dnsmasq_restart
    end

    def dnsmasq_restart
      `sudo systemctl restart dnsmasq.service`
    end

    def update_china_domains_list
      open(CHINA_DOMAINS_FILE, 'w') do |f|
        f << open(CHINA_DOMAINS_URL).read
      end
      dnsmasq_restart
    end

    private

    def gfwlist2dnsmasq
      File.expand_path('../../../bin/gfwlist2dnsmasq', __FILE__)
    end

    def g2d_config
      File.expand_path('../../../config/gfwlist2dnsmasq.yml', __FILE__)
    end

    def g2d_extras
      File.expand_path('../../../config/g2d_inclusive_hosts.yml', __FILE__)
    end

    def g2d_outfile
      File.expand_path('../../../shared/dnsmasq.d/gfwlist.conf', __FILE__)
    end
  end
end
