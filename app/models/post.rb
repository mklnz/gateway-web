class Post
  include Mongoid::Document
  field :title, type: String
  field :name, type: String
end
