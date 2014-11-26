# Be sure to restart your server when you modify this file.

#require 'action_dispatch/session/active_record_store'
#require 'active_record/session_store/session'
#require 'active_record/session_store/sql_bypass'
#require 'active_record/session_store/railtie' if defined?(Rails)
# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")


#Gestorlcc::Application.config.middleware.insert_after #ActionDispatch::Flash, LimitedSessions::Expiry, \         #recent_activity: 2.hours, max_session: 24.hours

# LimitedSessions::SelfCleaningSession.self_clean_sessions=1000
# LimitedSessions::SelfCleaningSession.max_session=12.hours
# LimitedSessions::SelfCleaningSession.recent_activity=2.hours

Gestorlcc::Application.config.session_store :active_record_store, :key => '_gestorlcc_session'

#Gestorlcc::Application.config.session_store :active_record_store
#ActionDispatch::Session::ActiveRecordStore.session_class = #LimitedSessions::SelfCleaningSession
