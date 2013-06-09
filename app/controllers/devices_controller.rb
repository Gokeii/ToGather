class DevicesController < ApplicationController
	before_filter :authenticate_user!
	def create
		device = current_user.build_device
		device.registration_id = params[:registration_id]
		device.save

		render  :status => 200,
						:json => 	{ :success => true,
												:info => "Device registered",
												:data => {} 
											}
	end
end
