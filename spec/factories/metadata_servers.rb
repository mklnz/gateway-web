FactoryGirl.define do
  factory :metadata_server do
    url 'https://example.org/endpoint1.json'
    priority 1

    factory :metadata_server_down do
      url 'https://example.org/endpoint1_down.json'
    end
  end
end
