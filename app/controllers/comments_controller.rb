class CommentsController < ApplicationController
	def create
		event = Event.find(params['event_id'])
		content = params['content']

		if  !current_user.nil?
			user_id = current_user.id
		else 
			user_id = 0
		end
		comment = Comment.build_from(event, user_id, content)

		unless params['user_name'].nil?
			comment.user_name = params['user_name']			
		end
		comment.save

		respond_to do |format|
			format.json {
				render  :status => 200,
								:json => 	{ 
									:success => true,
									:data => {}
								}
			}
		end
	end
end
