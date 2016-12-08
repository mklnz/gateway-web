class Server
  include Mongoid::Document
  include Mongoid::Timestamps

  field :node_id, type: Integer
  field :name, type: String
  field :host, type: String
  field :port, type: Integer
  field :password, type: String
  field :encryption_method, type: String
  field :timeout, type: Integer
  field :priority, type: Integer

  METHODS = ['rc4-md5', 'salsa20'].freeze

  validates :node_id, :name, :host, :port, :password, :encryption_method,
            :timeout, presence: true

  after_save :refresh_ss_config
  after_destroy :after_destroy

  scope :prioritize, -> { order(priority: :asc) }

  def self.active
    active_server_id = Setting.get('active_server_id')
    Server.find(active_server_id) unless active_server_id.nil?
  end

  def active?
    id == Setting.get('active_server_id')
  end

  def ss_config
    {
      server: host,
      server_port: port,
      local_address: '0.0.0.0',
      local_port: 1080,
      password: password,
      timeout: 60,
      method: encryption_method
    }.to_json
  end

  private

  def refresh_ss_config
    Setting.set('active_server_id', id) if active?
  end

  def after_destroy
    Setting.delete('active_server_id') if active?
  end
end
