require 'rails_helper'

describe ApiServer do
  let(:auth_email) { 'test@example.org' }
  let(:auth_token) { 'test12345' }

  let(:auth_headers) do
    {
      'X-User-Email' => auth_email,
      'X-User-Token' => auth_token
    }
  end

  before(:example) do
    Setting.set('cns_email', auth_email)
    Setting.set('cns_token', auth_token)
    @api_server = create(:api_server)
  end

  context 'fetch nodes' do
    let(:api_nodes) do
      [{ id: '1', name: 'hk1', host: '8.8.8.8', password: 'testmannz', port: 2001, method: 'rc4-md5', timeout: 60, priority: 1 },
       { id: '2', name: 'hk2', host: '8.8.4.4', password: 'testmannz', port: 2002, method: 'rc4-md5', timeout: 60, priority: 2 }]
    end

    let(:api_nodes_new_only) do
      [{ id: '3', name: 'hk3', host: '127.0.0.1', password: 'testmannz', port: 2003, method: 'rc4-md5', timeout: 60, priority: 1 }]
    end

    def server_response(ss_servers)
      ss_servers.to_json
    end

    def nodes_url(api_server)
      "#{api_server.url}/#{ApiServer::API_VERSION}/nodes.json"
    end

    it 'adds servers' do
      stub_request(:get, nodes_url(@api_server)).with(headers: auth_headers).to_return(
        body: server_response(api_nodes)
      )
      @api_server.sync_ss_servers

      expect(Server.count).to eq(api_nodes.count)
    end

    it 'removes old servers' do
      stub_request(:get, nodes_url(@api_server)).with(headers: auth_headers).to_return(
        body: server_response(api_nodes_new_only)
      )
      server = create(:server)
      @api_server.sync_ss_servers

      expect(Server.where(node_id: server.node_id).count).to eq(0)
      expect(Server.where(node_id: api_nodes_new_only.first[:id]).count).to eq(1)
    end

    it 'sets active SS server' do
      stub_request(:get, nodes_url(@api_server)).with(headers: auth_headers).to_return(
        body: server_response(api_nodes_new_only)
      )
      server = create(:server)
      Setting.set('active_server_id', server.id)

      @api_server.sync_ss_servers

      top_server = Server.prioritize.first
      expect(top_server.node_id.to_s).to eq(api_nodes_new_only.first[:id])
      expect(Setting.get('active_server_id')).to eq(top_server.id)
    end
  end

  context 'fetch tunnel server' do
    def tunnel_server_url(api_server)
      "#{api_server.url}/#{ApiServer::API_VERSION}/tunnel_server.json"
    end

    def server_response(tunnel_data)
      tunnel_data.to_json
    end

    let(:tunnel_server) do
      { id: 1, host: '127.0.0.1', port: 22,
        public_key: 'pub', private_key: 'priv' }
    end

    it 'syncs server' do
      stub_request(:get, tunnel_server_url(@api_server)).with(headers: auth_headers).to_return(
        body: server_response(tunnel_server)
      )
      @api_server.sync_tunnel_server

      expect(TunnelServer.count).to eq(1)
      expect(TunnelServer.first.host).to eq(tunnel_server[:host])
    end
  end
end
