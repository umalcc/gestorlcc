# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
#use LimitedSessions::Expiry, recent_activity: 2.hours, max_session: 24.hours
run Gestorlcc::Application
