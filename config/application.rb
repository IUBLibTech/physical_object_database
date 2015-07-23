require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'csv'


# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)


# Starts the digital file auto accepting thread 

module Pod
  class Application < Rails::Application
    require 'digital_file_auto_acceptor'
    # this fires up the background process that searches for physical objects to automatically move to accepted state
    # after 30/40 days from digitization start (video/audio)
    ::DigitalFileAutoAcceptor.instance.start
    
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    #config.time_zone = 'Eastern Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.i18n.enforce_available_locales = true

    #use rspec instead of default test framework
    config.generators do |g|
      g.test_framework :rspec
    end

    # Autoload lib/ folder including all subdirectories
    config.autoload_paths += Dir["#{config.root}/lib/**/"]

  end
end