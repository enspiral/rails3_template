puts "setting up Gemfile"
append_file 'Gemfile', "\n# Bundle gems needed for Haml\n"
gem 'haml'
gem 'haml-rails', :group => :development

append_file 'Gemfile', "\n# Bundle gems needed for Devise\n"
gem 'devise'
# the following gems are used to generate Devise views for Haml
gem 'hpricot', :group => :development
gem 'ruby_parser', :group => :development

#----------------------------------------------------------------------------
# jQuery
#----------------------------------------------------------------------------
gem 'jquery-rails', '0.2.6'

gem "xebec"
gem "will_paginate", "~> 3.0.pre2"

gem 'formtastic', '~> 1.1.0'
gem "friendly_id", "~> 3.2"
gem 'inherited_resources', '~> 1.2.1'
gem "compass"
gem 'hoptoad_notifier'

gem 'capistrano', :group => :development
gem 'steak', :groups => [:development, :test]

gem 'capybara', ">=0.3.6", :groups => [:development, :test]
gem 'database_cleaner', ">=0.5.0", :groups => [:development, :test]

append_file 'Gemfile', "\n# rspec-rails also install rspec\n"
gem "rspec-rails", "~> 2.4", :groups => [:development, :test]

#gem 'spork', ">=0.8.4", :group => :test

#----------------------------------------------------------------------------
# Install the gems
#----------------------------------------------------------------------------
run 'bundle install'