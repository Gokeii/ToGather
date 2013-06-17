class CommentsController < ApplicationController
	def create
		event = Event.find(params['event_id'])
		if params['user_name'].nil?
			user_id = current_user.id
		else 
			a = 'a'
		end
		content = params['content']
		comment = Comment.build_from(event, user_id, content)
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
