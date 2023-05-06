class HomeController < ApplicationController
  def index
    render json: 'Welcome to The Platform API'
  end
end
