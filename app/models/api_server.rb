class ApiServer
  include Mongoid::Document
  include Mongoid::Timestamps

  field :url, type: String
  field :priority, type: Integer

  default_scope -> { order(priority: :desc) }
end
