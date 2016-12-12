class ApiServer
  include Mongoid::Document
  include Mongoid::Timestamps

  API_VERSION = 'v1'.freeze

  field :url, type: String
  field :priority, type: Integer

  default_scope -> { order(priority: :desc) }

  def self.sync_all
    api_server = ApiServer.first
    api_server.sync_ss_servers
    api_server.sync_tunnel_server
  end

  def sync_ss_servers
    return unless Setting.auth_set?
    remote_servers = api_request(path: 'nodes.json', auth: true)
    Array(remote_servers).each do |rs|
      server = Server.find_or_create_by(node_id: rs['id'])
      server.update_attributes(
        name: rs['name'],
        host: rs['host'],
        port: rs['port'],
        password: rs['password'],
        encryption_method: rs['method'],
        timeout: rs['timeout'],
        priority: rs['priority']
      )
    end

    Server.where(:node_id.nin => remote_servers.map { |rs| rs['id'] }).destroy
    Setting.set(
      'active_server_id', Server.prioritize.first.id.to_s
    ) if Server.prioritize.first
  end

  def sync_tunnel_server
    tunnel_data = api_request(path: 'tunnel_server.json', auth: true)
    tunnel_server = TunnelServer.find_or_initialize_by(tunnel_id: tunnel_data['id'])
    tunnel_server.attributes = {
      host: tunnel_data['host'],
      port: tunnel_data['port'],
      remote_forward_port: tunnel_data['remote_forward_port'],
      public_key: tunnel_data['public_key'],
      private_key: tunnel_data['private_key'],
      host_key: tunnel_data['host_key']
    }
    tunnel_server.save
    TunnelServer.where(:tunnel_id.ne => tunnel_data['id']).destroy
  end

  private

  def api_request(path:, auth: false)
    if auth
      headers = {
        'X-User-Email' => Setting.get('cns_email'),
        'X-User-Token' => Setting.get('cns_token')
      }
    end

    response = open("#{url}/#{API_VERSION}/#{path}", headers).read
    JSON.parse(response)
  end
end
