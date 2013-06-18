class RepliesController < ApplicationController
	def create
		@event = Event.find(params[:event_id])
		@reply = @event.replies.build
		@reply.name = params[:name]
		unless current_user.nil?
			@reply.user = current_user
		end
		@reply.save

		chosen = params[:choices]
		
		unless chosen.nil?
			@event.choices.each do |choice|
				if chosen.has_key?(choice.number.to_s)
					crship = ChoiceReplyship.new
					crship.choice = choice
					crship.reply = @reply
					crship.save
				end
			end
		end

		respond_to do |format|
			format.html {redirect_to events_notification_path({:reply_name => params[:name], :event_id => params[:event_id]})}
			format.json {
				render  :status => 200,
								:json => 	{ :success => true,
														:data => {} 
													}
			}
		end		
	end
end
