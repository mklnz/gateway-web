class DashboardController < ApplicationController
  def index
    @server = Server.active
  end

  def api_update
    ApiServer.sync_all
  end
end
