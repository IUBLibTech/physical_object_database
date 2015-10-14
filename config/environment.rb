# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Use tag or commit hash as version string; sub removes tag from tag-hash output
APP_VERSION = `git describe --always`.sub(/.*-g/, '') unless defined? APP_VERSION

# Initialize the Rails application.
Pod::Application.initialize!
# Load TM formats, for development mode only
Dir.glob("app/models/*_tm.rb").sort.map { |tm| tm.gsub(/^app\/models\//, "").gsub(/\.rb$/, '').camelize.constantize.connection } if ENV['RAILS_ENV'] == 'development'
