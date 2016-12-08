require 'rails_helper'

describe Server do
  let(:active_server) do
    server = create(:server)
    Setting.set('active_server_id', server.id)
    server
  end

  it 'sets active' do
    expect(active_server.active?).to eq(true)
  end

  it 'deleting active server will update settings' do
    Setting.set('proxy_mode', 'foreign_servers')
    active_server.destroy
    expect(Setting.get('active_server_id')).to eq(nil)
    expect(Setting.get('proxy_mode')).to eq('')
  end
end
