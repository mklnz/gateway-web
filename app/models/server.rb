class Server
  include Mongoid::Document
  field :name, type: String
  field :host, type: String
  field :port, type: Integer
  field :password, type: String
  field :method, type: String
  field :timeout, type: Integer

  METHODS = ['rc4-md5', 'salsa20'].freeze

  validates :name, :host, :port, :password, :method, :timeout, presence: true

  after_save :refresh_ss_config

  def self.active
    active_server_id = Setting.get('active_server_id')
    Server.find(active_server_id) unless active_server_id.nil?
  end

  def active?
    id.to_s == Setting.get('active_server_id')
  end

  def ss_config
    {
      server: host,
      server_port: port,
      local_address: '0.0.0.0',
      local_port: 1080,
      password: password,
      timeout: 60,
      method: method
    }.to_json
  end

  private

  def refresh_ss_config
    Setting.set('active_server_id', id) if active?
  end
end
