class TunnelServer
  include Mongoid::Document
  include Mongoid::Timestamps

  field :tunnel_id, type: Integer
  field :host, type: String
  field :port, type: Integer
  field :remote_forward_port, type: Integer
  field :private_key, type: String
  field :public_key, type: String
  field :host_key, type: String

  after_save :refresh_tunnel

  private

  def refresh_tunnel
    return unless changed? && ENV['GATEWAY_DEVICE']
    Gateway::Tunnel.instance.save_tunnel_config(
      as_json.with_indifferent_access
    )
  end
end
