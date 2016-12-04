class SettingsController < ApplicationController
  def index
    @proxy_mode = Setting.get('proxy_mode')
    @email = Setting.get('cns_email')
    @token = Setting.get('cns_token')
  end

  def update
    params[:data].each do |k, v|
      Setting.set(k, v)
    end
    if request.referrer
      redirect_to request.referrer
    else
      redirect_to settings_path
    end
  end
end
