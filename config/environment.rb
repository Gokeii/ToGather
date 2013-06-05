# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
ToGather::Application.initialize!

ActionMailer::Base.smtp_settings = {
    :address => "smtp.gmail.com",
    :port => "587",
    :domain => "gmail.com",
    :authentication => "plain",
    :user_name => "togatherteam@gmail.com",
    :password => "3020103210",
    :enable_starttls_auto => true
}