# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Use tag or commit hash as version string; sub removes tag from tag-hash output
APP_VERSION = `git describe --always`.sub(/.*-g/, '') unless defined? APP_VERSION

# Initialize the Rails application.
Pod::Application.initialize!
