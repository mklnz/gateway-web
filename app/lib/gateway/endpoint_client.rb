module Gateway
  class EndpointClient < Base
    METADATA_URL =
      'https://raw.githubusercontent.com/mklnz/ruby-openwrt-endpoint/master/endpoint.json'.freeze
    CACHE = File.expand_path('../../config/endpoint.json', __FILE__).freeze

    def cache(reload: false)
      if @cache.nil? || reload
        reload_cache
      else
        @cache
      end
    end

    def endpoint_url
      cache['endpoint_url']
    end

    def update
      response = open(METADATA_URL).read
      data = JSON.parse(response)

      updated_at = DateTime.parse(data['updated_at'])
      local_updated_at = DateTime.parse(cache['updated_at'])

      write_cache(data) if updated_at > local_updated_at
    end

    private

    def reload_cache
      raw_cache = File.read(CACHE)
      @cache = JSON.parse(raw_cache)
    end

    def write_cache(data)
      File.open(CACHE, 'w') do |f|
        f.write(data.to_json)
      end
      reload_cache
    end
  end
end
