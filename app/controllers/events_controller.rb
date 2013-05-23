class EventsController < ApplicationController
	def index
		@events = Event.scoped
		@events = Event.between(params['start'], params['end']) if (params['start'] && params['end'])
		respond_to do |format|
			format.json { render :json => @events }
		end
	end

	def show
		@event = Event.find(params[:id])
	end

	def new
		@event = Event.new
	end

	def create
		event = Event.new
		event.title = params[:title]
		event.description = params[:description]
		event.start = 1.day.ago
		event.end = Time.now
		event.all_day = false
		event.user = current_user

		choices_count = params[:'choices-count'].to_i
		1.upto(choices_count) do |i|
			choice = event.choices.build
			choice.start_time = params["choice-start-"+i.to_s]
			choice.end_time = params["choice-end-"+i.to_s]
			choice.number = i
			choice.save
		end		

		event.save

		redirect_to calendar_index_path
	end
end
