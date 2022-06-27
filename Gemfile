source 'https://rubygems.org'

gem "puma", "~> 4.3"
#STANDARD CASES
#active_record-acts_as handles polymoriphic associations (technical metadata and it subsequent subclasses: open reel technical metatdata, disc technical metadata, etc)
gem "active_record-acts_as"

#allows like query syntax
gem 'activerecord-like', '0.0.6'

# counter_culture improves default count_cache handling and adds additional features
# removed; deprecate or resolve caching issue
# gem "counter_culture", "~> 0.1.18"

#nested_form handles form fields for the has_many objects associated to the main form object
gem "nested_form"

#gem "thin", "1.6.2"

#simple_enum handles the enumerated values for technical metadata fields (open reel tape size for instance)
#gem 'simple_enum'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.2.0'

# backported fixes for rack
gem 'rack', '~> 1.6.13', git: 'https://github.com/rails-lts/rack.git', branch: 'lts-1-6-stable'

# Use mysql as the database for Active Record
gem 'mysql2', '~> 0.4.10'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use for pagination
gem 'will_paginate', '~> 3.0'

# Use CoffeeScript for .js.coffee assets and views
#gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# below deprecated in favor of nodejs
# gem 'therubyracer', platforms: :ruby

# ruby 2.7 support for activesupport 4.2.x
gem 'bigdecimal', '~> 1.4.4'

# Use jquery as the JavaScript library
gem 'jquery-rails'
# User jquery-ui
gem 'jquery-ui-rails', '~> 5.0'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
#gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

gem 'json'

gem 'config'

# roo adds XLSX read-only support
gem 'roo'

# pundit adds authorization support
gem 'pundit'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
  gem 'rdoc'
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
  #allows capybara access to session variable
  gem 'rack_session_access'
  gem 'rspec-rails'
  gem 'webmock'
  gem 'byebug'
end

group :development do
  gem 'spring-commands-rspec'
end

group :test do
  gem 'capybara'
  #for capybara javascript access
  gem 'selenium-webdriver'
  gem 'webdrivers'
  gem 'launchy' # for viewing capybara pages
  gem 'connection_pool' # for sharing client/server session in capybara tests with js: true
  gem 'factory_bot_rails', '~> 4.8'
  #gem 'cucumber', '1.2.5' # Spork not supported as of Cucumber 1.3.0, need to use 1.2.5
  gem 'cucumber-rails', :require => false
  gem 'database_cleaner'
  gem 'simplecov', require: false
  gem 'coveralls', '~> 0.8.23', require: false
end

group :production do
  # gem "thin", "1.6.2"
end

# hold back to earlier spring to avoid newer rails requirement
gem 'spring', '~>2.1'
