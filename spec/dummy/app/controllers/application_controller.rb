class ApplicationController < ActionController::Base
  include Touchpoints::Tracker

  def show
    render body: 'Welcome!!'
  end
end
