module Gateway
  class MetadataClient < Base
    def update(url)
      response = open(url).read
      data = JSON.parse(response)
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
