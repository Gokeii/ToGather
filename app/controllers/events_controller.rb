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
																				'is_closed' => invitation.event.is_closed
																			 }
			end
			I18n.locale = 'en'
		else
			@launched_events = current_user.events
			# @invited_events = []
			# current_user.invitations.each do |invitation|
			# 	@invited_events.push(invitation.event)
			# end

			@participated_events = []
			current_user.replies.each do |reply|
				unless @participated_events.include? reply.event
					@participated_events.push(reply.event)
				end
			end

			@launched_events.sort!{|a,b|b.updated_at <=> a.updated_at}
			# @invited_events.sort!{|a,b|b.updated_at <=> a.updated_at}
			@participated_events.sort!{|a,b|b.updated_at <=> a.updated_at}
		end

		respond_to do |format|
			format.html
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
		@replies_count = @event.replies.count

		# wait for implement
		@comments_count = @event.root_comments.count

		@comments = @event.root_comments
		@comments.sort!{|a,b|b.updated_at <=> a.updated_at}

		@latest_activity = @event.updated_at

		@is_owner = current_user == @event.user

		@is_closed = @event.is_closed

		respond_to do |format|
			format.json {
				choices = {}
				@event.choices.each do |choice|
					names = []
					choice.replies.each do |reply|
						names.push(reply.name)
					end
					choices[choice.number] = {
						'time' => choice.start_time.strftime('%Y-%m-%d\n%I:%M%p'),
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
		event.emails = params[:emails]

		choices_count = params[:'choices-count'].to_i
		1.upto(choices_count) do |i|
			choice = event.choices.build
			choice.start_time = params["choice-start-"+i.to_s]
			choice.end_time = params["choice-end-"+i.to_s]
			choice.number = i
			choice.save
		end

		emails = params['emails']
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

		#push notification to android end if user invited have device registered
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

		if emails.strip.length != 0
			UserMailer.invite(current_user, emails, event.title, event.description, event_url(event)).deliver
		end

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

		#close poll
		if !params['is_closed'].nil?
			@event.is_closed = params['is_closed']

			if params['decision-count'].to_i > 0
				decisions = @event.build_decision
				@event.choices.each do |choice|
					if !params['decision-'+choice.number.to_s].nil?
						decisions.choices << choice
					end
				end
				decisions.save
			end

			@event.save

		#edit poll
		else
			@event.update_attributes(params[:event])
			emails = @event.emails
			emailList = []
			@event.invitations.each do |invitation|
				emailList.push(invitation.email)
			end
			newEmailList = @event.emails.split(',')
			sendList = ''
			newEmailList.each do |email|
				unless emailList.include? email
					sendList += email + ','

					invitation = @event.invitations.build
					invitation.email = email
					invitee = User.where(:email => email).first
					if !invitee.nil?
						invitation.user = invitee
					end
					invitation.save
				end
			end

			if sendList.strip.length != 0
			UserMailer.invite(current_user, sendList, @event.title, @event.description, event_url(@event)).deliver
		end


			choices_count = params[:'choices-count'].to_i
			choices = @event.choices
			index = 0
			count = choices.count
			1.upto(choices_count) do |i|
				start_time = params["choice-start-"+i.to_s]
				end_time = params["choice-end-"+i.to_s]
				
				while index < count && start_time > choices[index].start_time
					index += 1
				end

				unless index < count && !(start_time < choices[index].start_time)
					choice = @event.choices.build
					choice.start_time = start_time
					choice.end_time = end_time
					choices.insert(index, choice)
					count += 1
				end
			end

			1.upto(count) do |i|
				choices[i-1].number = i
				choices[i-1].save
			end
		end

		respond_to do |format|
			format.html {
				redirect_to event_path(@event)
			}
			format.json {
				render :status => 200,
						   :json   => { :success => true,
												    :data => {}
											    }
			}
		end
	end

	def edit
		@event = Event.find(params[:id])
	end

	def notification
		@reply_name = params[:reply_name]
		@event_id = params[:event_id]
	end
end
