# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
# (commented out to use the latest installed version of rails)
#RAILS_GEM_VERSION = '2.3.4' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

# Evil hack to workaround https://github.com/rubygems/rubygems/issues/171
# (see also hawk/lib/tasks/lang.rake)
begin
  Gem.all_load_paths
rescue NoMethodError
  module Gem
    def self.all_load_paths
      []
    end
  end
end

# Hack to fix vendor gems not loading beacuse railties uses old
# Gem::SourceIndex#add_spec which doesn't work with rubygems 1.8
if defined?(Gem::Specification.add_spec)
  Gem.source_index.each do |name,spec|
    Gem::Specification.add_spec spec
  end
end

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"
  config.gem "locale"
  config.gem "locale_rails"
  config.gem "gettext"
  config.gem "gettext_rails"
  config.gem "rack"

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]
  config.frameworks -= [ :active_record ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de

  config.middleware.use "PerRequestCache"
end

# Unset 'TERM' to avoid crm shell putting curses junk in its output
ENV.delete 'TERM'

