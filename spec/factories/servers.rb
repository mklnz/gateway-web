FactoryGirl.define do
  factory :server do
    node_id 1
    name 'example-1'
    host 'node.example.org'
    port 1080
    password 'lollipop123'
    encryption_method 'rc4-md5'
    timeout 60
  end
end
