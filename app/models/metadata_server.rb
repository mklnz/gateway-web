class MetadataServer
  include Mongoid::Document
  include Mongoid::Timestamps

  field :url, type: String
  field :priority, type: Integer

  default_scope -> { order(priority: :asc) }

  def self.sync_all
    MetadataServer.order(priority: :asc).each do |ms|
      return true if ms.sync
    end
  end

  def sync
    json_data = fetch_json_data
    metadata_server_data = json_data['metadata_servers']
    api_server_data = json_data['api_servers']

    sync_metadata_servers(metadata_server_data)
    sync_api_servers(api_server_data)

    true
  rescue StandardError
    false
  end

  private

  def fetch_json_data
    response = open(url).read
    JSON.parse(response)
  end

  def sync_metadata_servers(server_data)
    Array(server_data).each do |sd|
      server = MetadataServer.find_or_create_by(url: sd['url'])
      server.priority = sd['priority']
      server.save
    end

    MetadataServer.where(:url.nin => server_data.map { |sd| sd['url'] }).destroy
  end

  def sync_api_servers(server_data)
    Array(server_data).each do |sd|
      server = ApiServer.find_or_create_by(url: sd['url'])
      server.priority = sd['priority']
      server.save
    end

    ApiServer.where(:url.nin => server_data.map { |sd| sd['url'] }).destroy
  end
end
