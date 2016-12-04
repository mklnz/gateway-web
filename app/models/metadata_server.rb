class MetadataServer
  include Mongoid::Document
  include Mongoid::Timestamps

  field :url, type: String
  field :priority, type: Integer

  default_scope -> { order(priority: :desc) }

  def self.sync_all
    MetadataServer.order(priority: :asc).each do |ms|
      return true if ms.sync
    end
  end

  def self.clean_outdated(current_updated)
    ApiServer.where(:updated_at.lt => current_updated).destroy_all
    MetadataServer.where(:updated_at.lt => current_updated).destroy_all
  end

  def sync
    json_data = fetch_json_data
    metadata_server_data = json_data['metadata_servers']
    api_server_data = json_data['api_servers']
    remote_updated_at = DateTime.parse(json_data['updated_at'])
    return true if updated_at >= remote_updated_at

    sync_metadata_servers(metadata_server_data, remote_updated_at)
    sync_api_servers(api_server_data)

    MetadataServer.clean_outdated(remote_updated_at)
    true
  rescue StandardError
    false
  end

  private

  def fetch_json_data
    response = open(url).read
    JSON.parse(response)
  end

  def sync_metadata_servers(server_data, updated_at = Time.zone.now)
    Array(server_data).each do |sd|
      server = MetadataServer.find_or_create_by(
        url: sd['url']
      )
      server.priority = sd['priority']
      server.updated_at = updated_at
      server.save
    end
  end

  def sync_api_servers(server_data, updated_at = Time.zone.now)
    Array(server_data).each do |sd|
      server = ApiServer.find_or_create_by(url: sd['url'])
      server.priority = sd['priority']
      server.updated_at = updated_at
      server.save
    end
  end
end
