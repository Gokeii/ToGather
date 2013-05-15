class EventsController < ApplicationController
	def index
		@events = Event.scoped
		@events = Event.between(params['start'], params['end']) if (params['start'] && params['end'])
		respond_to do |format|
			format.json { render :json => @events }
		end
	end
end
