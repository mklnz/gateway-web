class ServersController < ApplicationController
  before_action :set_server, only: [:show, :edit, :update, :destroy]

  def index
    @servers = Server.all
  end

  def show
  end

  def new
    @server = Server.new(default_attributes)
  end

  def edit
  end

  def create
    @server = Server.new(server_params)
    if @server.save
      redirect_to @server
    else
      render :new
    end
  end

  def update
    if @server.update(server_params)
      redirect_to @server, notice: 'Server was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @server.destroy
    redirect_to servers_path, notice: 'Server was successfully destroyed.'
  end

  private

  def default_attributes
    { timeout: 60, method: 'rc4-md5' }
  end

  def set_server
    @server = Server.find(params[:id])
  end

  def server_params
    params.require(:server).permit(
      :name, :host, :port, :password, :method, :timeout
    )
  end
end
