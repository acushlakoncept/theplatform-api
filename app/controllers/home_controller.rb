class HomeController < ApplicationController
  def index
    render json: "Welcome to #{APP_CONFIG.app_name}"
  end
end
