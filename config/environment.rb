# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Gestorlcc::Application.initialize!
ActionMailer::Base.default :content_type => "text/html"

