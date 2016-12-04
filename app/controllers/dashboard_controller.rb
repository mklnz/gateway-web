class DashboardController < ApplicationController
  def index
    @server = Server.active
  end

  def api_update
    Setting.api_update
  end
end
