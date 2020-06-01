class ApplicationController < ActionController::Base
  include Touchpoints::Tracker

  def show
    render body: current_user.present? ? 'Hi!' : 'Log in'
  end

  def current_user
    User.new(id: session[:user_id]) if session[:user_id]
  end
end
