# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.1.0' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use (only works if using vendor/rails).
  # To use Rails without a database, you must remove the Active Record framework
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Only load the plugins named here, in the order given. By default, all plugins 
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random, 
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => '_Books_session',
    :secret      => '8201459b0362ed8685d5572143e685873343845e31a3ba83eac7a87ca6f94c474c26319a9c5e16f6b6854a1ba6d8d936f9b28e189f1a092c6f2551a853f7690e'
  }

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  config.action_mailer.delivery_method = :smtp

end

gem 'mislav-will_paginate', '~> 2.2'
require 'will_paginate'


AutoAdmin.config do |admin|
   # This information is used by the theme to construct a useful
   # header; the first parameter is the full URL of the main site, the
   # second is the displayed name of the site, and the third (optional)
   # parameter is the title for the administration site.
   admin.set_site_info 'http://www.bookreadingroom.com/', 'bookreadingroom.com'

   # "Primary Objects" are those for which lists should be directly
   # accessible from the home page.
   admin.primary_objects = %w(book comment notification user)
   admin.admin_model = "user"
   admin.admin_model_id = 1

   #admin.save_as = %w(csv)
   admin.theme = :django # Optional; this is the default.
 end
=begin
 ActionMailer::Base.server_settings = {
 :address => "mail.bookreadingroom.com",
 :port => 25,
 :domain => "bookreadingroom.com",
 :authentication => :login,
 :user_name => "serveradmin@bookreadingroom.com",
 :password =>⁞ ""
 }
=end

ActionMailer::Base.smtp_settings = {
  :address => "smtp.gmail.com",
  :port => 587,
  :domain => "bookreadingroom.com",
  :authentication => :plain,
  :user_name => "admin@bookreadingroom.com",
  :password => "booksadmin123"
}

MailFetcher.config = { :server => "imap.gmail.com", :username => "admin@bookreadingroom.com", :password => "booksadmin123", :port     => 993 }

MailFetcher.mailer_class = :my_mailer 

 