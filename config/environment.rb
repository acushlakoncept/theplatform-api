# Load the Rails application.
require_relative "application"

# Initialize the Rails application.
Rails.application.initialize!

# We will move this to environment specific

ActionMailer::Base.smtp_settings = {
  :user_name => 'apikey', 
  :password => ENV['SENDGRID_PASSWORD'],
  :domain => 'localhost',
  :address => 'smtp.sendgrid.net',
  :port => 587,
  :authentication => :plain,
  :enable_starttls_auto => true
}