# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Use tag or commit hash as version string; sub removes tag from tag-hash output
APP_VERSION = `git describe --always`.sub(/.*-g/, '') unless defined? APP_VERSION

# Initialize the Rails application.
Pod::Application.initialize!

# Initialize TM formats
puts "\n\n\n\n\nFoobar"
Dir.glob("app/models/*_tm.rb").sort.map { |tm| tm.gsub(/^app\/models\//, "").gsub(/\.rb$/, '').camelize.constantize.connection }
Dir.glob("app/models/*_tm.rb").sort.map { |tm| puts "here?", tm.gsub(/^app\/models\//, "").gsub(/\.rb$/, '').camelize }
TechnicalMetadatumModule.set_tm_constants
puts "Foobar\n\n\n\n\n"