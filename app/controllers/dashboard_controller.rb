class DashboardController < ApplicationController
  def index
    @server = Server.active
  end
end
