source 'https://rubygems.org'
#SPECIAL CASES
#spork granch to fix uninitialized constant RSpec::Core::CommandLine (NameError)
gem "spork", git: 'https://github.com/codecarson/spork.git', branch: 'rspec3_runner'

#STANDARD CASES
#act_as_relation handles polymoriphic associations (technical metadata and it subsequent subclasses: open reel technical metatdata, disc technical metadata, etc)
gem "acts_as_relation"

#nested_form handles form fields for the has_many objects associated to the main form object
gem "nested_form"

gem "thin", "1.6.2"

#simple_enum handles the enumerated values for technical metadata fields (open reel tape size for instance)
#gem 'simple_enum'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.2'

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
end

group :test do
  gem 'rspec-rails'
  gem 'selenium-webdriver', '2.35.1'
  gem 'capybara'
  gem 'factory_girl_rails'
  #gem 'cucumber', '1.2.5' # Spork not supported as of Cucumber 1.3.0, need to use 1.2.5
  gem 'cucumber-rails', :require => false
  gem 'database_cleaner'
end
