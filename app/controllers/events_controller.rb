class EventsController < ApplicationController
	before_filter :authenticate_user!, :except => :show

	def index
		@events = Event.scoped
		@events = Event.between(params['start'], params['end']) if (params['start'] && params['end'])
		respond_to do |format|
			format.json { render :json => @events }
		end
	end

	def show
		@event = Event.find(params[:id])

		invitations = @event.invitations
		@replies_count = 0;
		1.upto(invitations.length) do |i|
			@replies_count += 1 unless invitations[i-1].reply.nil?
		end

		# wait for implement
		@comments_count = 0;

		@latest_activity = @event.updated_at

	end

	def new
		@event = Event.new
	end

	def create
		event = Event.new
		event.title = params[:title]
		event.description = params[:description]
		event.location = params[:location]
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

		emails = params[:emails]
		invitations_count = emails.split(',').length
		1.upto(invitations_count) do |i|
			invitation = event.invitations.build
			invitation.email = emails.split(',')[i-1]
			invitation.save
		end

		event.save

		api_key = 'AIzaSyBjg1TQV-puS06AAREhRnkFj2edW6dPtoE'
		gcm = GCM.new(api_key)
		registration_ids = []
		options = {data: {}, collapse_key: "new invitation"}
		emails.split(',').each do |email|
			client = User.where(:email => email).first
			if !client.nil? && !client.device.nil?
				registration_ids.push(client.device.registration_id)
			end
		end
		if registration_ids.size > 0
			response = gcm.send_notification(registration_ids, options)
			Rails.logger.debug('debug::' + response.to_json)
		end

		UserMailer.invite(current_user, emails, event.title, event.description, event_url(event)).deliver

		respond_to do |format|
			format.json {
				render :status => 200,
						   :json   => { :success => true,
												    :info => "event created",
												    :data => { :event => event.to_json}
											    }
			}
			format.html {
				redirect_to event_path(event)
			}
		end
		
	end

	def notification
		@reply_name = params[:reply_name]
		@event_id = params[:event_id]
	end
end
