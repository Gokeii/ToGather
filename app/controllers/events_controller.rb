class EventsController < ApplicationController
	include ActionView::Helpers::DateHelper
	before_filter :authenticate_user!, :except => :show

	def index
		if !params['launch'].nil?
			I18n.locale = 'zh-CN'
			@events = {}
			current_user.events.each do |event|
				@events[event.id] = {'title' => event.title,
														 'time' => time_ago_in_words(event.created_at),
														 'is_closed' => event.is_closed
														}
			end
			I18n.locale = 'en'
		elsif !params['invited'].nil?			
			I18n.locale = 'zh-CN'
			@events = {}
			current_user.invitations.each do |invitation|
				@events[invitation.event.id] = {'title' => invitation.event.title, 
																				'time' => time_ago_in_words(invitation.event.created_at),
																				'is_closed' => event.is_closed
																			 }
			end
			I18n.locale = 'en'
		else
			@events = Event.scoped
			@events = Event.between(params['start'], params['end']) if (params['start'] && params['end'])
		end

		respond_to do |format|
			format.json { 
				if !params['launch'].nil? || !params['invited'].nil?
					render 				:status => 200,
												:json => 	{ :success => true,
																		:data => @events.to_json
																	}
				else 
					render :json => @events
				end
			}
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

		respond_to do |format|
			format.json {
				choices = {}
				@event.choices.each do |choice|
					names = []
					choice.replies.each do |reply|
						names.push(reply.name)
					end
					choices[choice.number] = {
						'time' => choice.start_time.strftime('%Y-%m-%d\n%I:%M %p'),
						'count' => choice.replies.size,
						'names' => names
					}
				end

				render  :status => 200,
				:json => 	{ :success => true,
										:data => { 'title' => @event.title,
															 'time' => @event.created_at.strftime('%Y-%m-%d'),
															 'description' => @event.description,
															 'choices' => choices
														 } 
									}
			}
			format.html
		end
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
			invitee = User.where(:email => emails.split(',')[i-1]).first
			if !invitee.nil?
				invitation.user = invitee
			end
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
												    :data => { :id => event.id}
											    }
			}
			format.html {
				redirect_to event_path(event)
			}
		end
		
	end

	def update
		@event = Event.find(params[:id])
		if !params['is_closed'].nil?
			@event.is_closed = params['is_closed']
			@event.save
		end

		respond_to do |format|
			format.json {
				render :status => 200,
						   :json   => { :success => true,
												    :data => {}
											    }
			}
		end
	end

	def notification
		@reply_name = params[:reply_name]
		@event_id = params[:event_id]
	end
end
