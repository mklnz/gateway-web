require 'sinatra'
require 'byebug' if settings.development?

require_relative 'lib/gateway'

Tilt.register Tilt::ERBTemplate, 'html.erb'
set :bind, '0.0.0.0'
set :public_folder, File.dirname(__FILE__) + '/public'

def gateway
  Gateway.new
end

get '/' do
  @stats = gateway.stats
  erb :index
end

get '/settings' do
  @inclusive_hosts = gateway.inclusive_hosts.join("\n")
  erb :settings
end

post '/settings/inclusive-hosts' do
  hosts = params['inclusive_hosts'].lines.map(&:chomp)
  gateway.inclusive_hosts = hosts
  redirect to('/settings')
end

post '/gfwlist/update' do
  gateway.dns.update_gfwlist
  redirect to('/')
end

post '/ipset/flush' do
  gateway.firewall.flush_ipset
  redirect to('/')
end

post '/tunnel/restart' do
  gateway.tunnel.restart
  redirect to('/')
end
