class RegistrationsController < Devise::RegistrationsController
	skip_before_filter 	:verify_authenticity_token,
											:if => Proc.new { |c| c.request.format == 'application/json' }

	def create
		build_resource
		resource.name = params["user"]["email"].split("@").first

		respond_to do |format|
			format.json {
				if resource.save
					sign_in resource
					render 	:status => 200,
									:json =>  { :success => true,
															:info => "Registered",
															:data => 	{ :user => resource,
																					:auth_token => current_user.authentication_token } 
														}
				else
					render 	:status => 	:unprocessable_entity,
															:json => 	{ :success => false,
																					:info => resource.errors,
																					:data => {} 
																				}
				end
			}

			format.html {
				if resource.save
				  if resource.active_for_authentication?
				    set_flash_message :notice, :signed_up if is_navigational_format?
				    sign_in(resource_name, resource)
				    respond_with resource, :location => after_sign_up_path_for(resource)
				  else
				    set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
				    expire_session_data_after_sign_in!
				    respond_with resource, :location => after_inactive_sign_up_path_for(resource)
				  end
				else
				  clean_up_passwords resource
				  respond_with resource
				end
			}
		end
	end
end
