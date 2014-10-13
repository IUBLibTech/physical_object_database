source 'https://rubygems.org'
#SPECIAL CASES
#spork granch to fix uninitialized constant RSpec::Core::CommandLine (NameError)
gem "spork", git: 'https://github.com/codecarson/spork.git', branch: 'rspec3_runner'

#STANDARD CASES
#act_as_relation handles polymoriphic associations (technical metadata and it subsequent subclasses: open reel technical metatdata, disc technical metadata, etc)
gem "acts_as_relation"

#counter_culture improves default count_cache handling and adds additional features
gem "counter_culture", "~> 0.1.18"

#nested_form handles form fields for the has_many objects associated to the main form object
gem "nested_form"

gem "thin", "1.6.2"

#simple_enum handles the enumerated values for technical metadata fields (open reel tape size for instance)
#gem 'simple_enum'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.0'

# Use mysql as the database for Active Record
gem 'mysql2'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
#gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# User jquery-ui
gem 'jquery-ui-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
#gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.1.2'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

group :development, :test do
  gem 'childprocess'
  gem 'guard-livereload'
  gem 'guard-rspec'
  gem 'guard-spork'
  #allows capybara access to session variable
  gem 'rack_session_access'
  gem 'rspec-rails'
  gem 'spork-rails', '~> 4.0.0'
end

group :development do
  gem 'debugger'
  gem 'spring'
end

group :test do
  gem 'selenium-webdriver', '2.35.1'
  gem 'capybara'
  #for capybara javascript access
  gem 'capybara-webkit'
  gem 'launchy' # for viewing capybara pages
  gem 'connection_pool' # for sharing client/server session in capybara tests with js: true
  gem 'factory_girl_rails'
  #gem 'cucumber', '1.2.5' # Spork not supported as of Cucumber 1.3.0, need to use 1.2.5
  gem 'cucumber-rails', :require => false
  gem 'database_cleaner'
end
