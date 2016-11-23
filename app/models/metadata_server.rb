class MetadataServer
  include Mongoid::Document
  include Mongoid::Timestamps

  field :url, type: String
  field :priority, type: Integer

  default_scope -> { order(priority: :desc) }

  def self.fetch_data
    local_updated_at = Setting.get('metadata_updated_at')

    MetadataServer.all.each do |s|
      begin
        response = open(s.url).read
        metadata = JSON.parse(response)
        server_updated_at = DateTime.parse(metadata['updated_at'])

        break if local_updated_at.present? && local_updated_at >= server_updated_at

        MetadataServer.sync(metadata)

        Setting.set('metadata_updated_at', Time.zone.now)
        break
      rescue StandardError => e
        next
      end
    end
  end

  def self.sync(metadata)
    Array(metadata['api_servers']).each do |ad|
      api_server = ApiServer.find_or_create_by(url: ad['url'])
      api_server.priority = ad['priority']
      api_server.updated_at = metadata['updated_at']
      api_server.save
    end

    Array(metadata['metadata_servers']).each do |md|
      metadata_server = MetadataServer.find_or_create_by(url: md['url'])
      metadata_server.priority = md['priority']
      metadata_server.updated_at = metadata['updated_at']
      metadata_server.save
    end

    ApiServer.where(:updated_at.lt => metadata['updated_at']).destroy_all
    MetadataServer.where(:updated_at.lt => metadata['updated_at']).destroy_all
  end
end
