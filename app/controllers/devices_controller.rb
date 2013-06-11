class DevicesController < ApplicationController
	before_filter :authenticate_user!
	def create
		device = Device.where(:registration_id => params[:registration_id]).first
		if device.nil?
			device = current_user.build_device
			device.registration_id = params[:registration_id]
			device.save
		else
			device.user = current_user
			device.save
		end

		render  :status => 200,
						:json => 	{ :success => true,
												:info => "Device registered",
												:data => {} 
											}
	end
end
