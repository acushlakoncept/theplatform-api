# Load the Rails application.
require_relative "application"

# Initialize the Rails application.
Rails.application.initialize!

# We will move this to environment specific

# Moving this to production specific env
# Only use sendgrid on prod, use mailcatcher for local env

# ActionMailer::Base.smtp_settings = {
#   :user_name => 'apikey', 
#   :password => ENV['SENDGRID_PASSWORD'],
#   :domain => 'localhost',
#   :address => 'smtp.sendgrid.net',
#   :port => 587,
#   :authentication => :plain,
#   :enable_starttls_auto => true
# }