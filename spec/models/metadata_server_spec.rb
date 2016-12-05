require 'rails_helper'

describe MetadataServer do
  let(:api_servers_json) do
    [{ url: 'https://api1.example.org', priority: 2 },
     { url: 'https://api2.example.org', priority: 1 }]
  end

  let(:api_servers_delete_json) do
    [{ url: 'https://api2.example.org', priority: 1 },
     { url: 'https://api3.example.org', priority: 2 }]
  end

  let(:metadata_servers_json) do
    [{ url: 'https://example.org/endpoint1.json', priority: 2 },
     { url: 'https://example.org/endpoint2.json', priority: 1 }]
  end

  let(:metadata_servers_delete_json) do
    [{ url: 'https://example.org/endpoint2.json', priority: 1 },
     { url: 'https://example.org/endpoint3.json', priority: 2 }]
  end

  def server_response(api_servers, metadata_servers)
    {
      api_servers: api_servers, metadata_servers: metadata_servers
    }.to_json
  end

  context 'Sync each' do
    before(:example) do
      @metadata_server = create(:metadata_server)
      stub_request(:get, @metadata_server.url).to_return(
        body: server_response(api_servers_json, metadata_servers_json)
      )
    end

    it 'sync adds entries' do
      @metadata_server.sync
      expect(MetadataServer.count).to eq(2)
      expect(MetadataServer.where(url: metadata_servers_json.last[:url]).count)
        .to eq(1)
      expect(ApiServer.count).to eq(2)
    end

    it 'syncs and updates existing entry' do
      api_server = create(:api_server)
      @metadata_server.sync

      # Updates priority on servers
      updated_server = MetadataServer.where(url: metadata_servers_json.first[:url]).first

      expect(updated_server.priority).to eq(2)
      expect(ApiServer.find_by(url: api_server.url).priority).to eq(2)
    end
  end

  context 'Sync all' do
    let(:metadata_servers_down_json) do
      [{ url: 'https://example.org/endpoint1_down.json', priority: 1 },
       { url: 'https://example.org/endpoint2.json', priority: 2 }]
    end

    it 'sync all removes old servers' do
      @metadata_server = create(:metadata_server)
      @api_server = create(:api_server)
      stub_request(:get, @metadata_server.url).to_return(
        body: server_response(api_servers_delete_json, metadata_servers_delete_json)
      )

      MetadataServer.sync_all

      expect(MetadataServer.count).to eq(2)
      expect(MetadataServer.where(url: @metadata_server.url).count)
        .to eq(0)
      expect(ApiServer.where(url: @api_server.url).count).to eq(0)
    end

    it 'syncs from 2nd up server' do
      @metadata_server_down = create(:metadata_server_down, priority: 1)
      @metadata_server = create(:metadata_server, priority: 2)
      stub_request(:get, @metadata_server_down.url).to_return(status: 404)
      stub_request(:get, @metadata_server.url).to_return(
        body: server_response(api_servers_json, metadata_servers_json)
      )

      MetadataServer.sync_all

      expect(MetadataServer.count).to eq(2)
      expect(MetadataServer.where(url: @metadata_server_down.url).count).to eq(0)
      expect(ApiServer.count).to eq(2)
    end
  end
end
