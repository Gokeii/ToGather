class CalendarController < ApplicationController
	protect_from_forgery :except => :index
  before_filter :authenticate_user!

  def index
  end
end
