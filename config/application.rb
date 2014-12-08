require File.expand_path('../boot', __FILE__)
#require 'active_support/core_ext'
require 'rails/all'
require 'sprockets/railtie'


# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module Gestorlcc
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{Rails.root}/lib)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

  config.time_zone = 'UTC'
  config.action_mailer.delivery_method = :smtp
   config.action_mailer.smtp_settings = {
     :address => "150.214.108.1" ,
     :port => 25,
     :domain => "lcc.uma.es" ,
     #:authentication => :login,
     #:user_name => "reservas" ,
     #:password => "aquimandoyo"
    }
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
 # config.action_mailer.default_content_type = "text/plain"
#ActionMailer::Base.default :content_type => "text/html"
config.middleware.use ActionDispatch::Flash
#config.middleware.insert_after ActionDispatch::Flash, LimitedSessions::Expiry, recent_activity: 2.hours, max_session: 24.hours
  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
  config.session_store(:cookie_store, {:key => '_gestorlcc_session'})
  config.assets.enabled = true
 
 # Version of your assets, change this if you want to expire all your assets
  config.assets.version = '1.0'
  # Do not compress assets
  config.assets.compress = false
  # Expands the lines which load the assets
  config.assets.debug = true


  end
end
