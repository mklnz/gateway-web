require 'rails_helper'

describe MetadataServer do
  # let(:metadata_server) { create(:metadata_server) }

  let(:api_servers_json) do
    [{ url: 'https://api1.example.org', priority: 1 },
     { url: 'https://api2.example.org', priority: 2 }]
  end

  let(:metadata_servers_json) do
    [{ url: 'https://example.org/endpoint1.json', priority: 2 },
     { url: 'https://example.org/endpoint2.json', priority: 1 }]
  end

  let(:metadata_servers_delete_json) do
    [{ url: 'https://example.org/endpoint2.json', priority: 1 },
     { url: 'https://example.org/endpoint3.json', priority: 2 }]
  end

  def server_response(api_servers, metadata_servers, updated_at = Time.zone.now)
    {
      updated_at: updated_at,
      api_servers: api_servers,
      metadata_servers: metadata_servers
    }.to_json
  end

  context 'Sync each' do
    before(:example) do
      Timecop.travel(1.hour.ago) { @metadata_server = create(:metadata_server) }
      stub_request(:get, @metadata_server.url).to_return(
        body: server_response(api_servers_json, metadata_servers_json)
      )
      @metadata_server.sync
    end

    it 'sync adds entries' do
      expect(MetadataServer.count).to eq(2)
      expect(MetadataServer.last.url).to eq(metadata_servers_json.last[:url])
    end

    it 'syncs and updates existing entry' do
      # Updates priority on first metadata server
      expect(MetadataServer.first.url).to eq(metadata_servers_json.first[:url])
      expect(MetadataServer.first.priority).to eq(2)
    end
  end

  context 'Sync all' do
    let(:metadata_servers_down_json) do
      [{ url: 'https://example.org/endpoint1_down.json', priority: 1 },
       { url: 'https://example.org/endpoint2.json', priority: 2 }]
    end

    it 'syncs from 2nd up server' do
      Timecop.travel(1.hour.ago) do
        @metadata_server_down = create(:metadata_server_down, priority: 1)
        @metadata_server = create(:metadata_server, priority: 2)
      end
      stub_request(:get, @metadata_server_down.url).to_return(status: 404)
      stub_request(:get, @metadata_server.url).to_return(
        body: server_response(api_servers_json, metadata_servers_json)
      )

      MetadataServer.sync_all
      md_servers = MetadataServer.order(updated_at: :asc)

      expect(md_servers.count).to eq(2)
      expect(md_servers.last.url).to eq(metadata_servers_json.last[:url])
    end

    it 'sync all removes old servers' do
      Timecop.travel(1.hour.ago) { @metadata_server = create(:metadata_server) }
      stub_request(:get, @metadata_server.url).to_return(
        body: server_response(api_servers_json, metadata_servers_delete_json)
      )

      MetadataServer.sync_all

      expect(MetadataServer.count).to eq(2)
      expect(MetadataServer.where(url: @metadata_server.url).count)
        .to eq(0)
    end
  end
end
