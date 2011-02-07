gem 'formtastic', '~> 1.1.0'
gem "friendly_id", "~> 3.2"
gem 'inherited_resources', '~> 1.2.1'
gem "compass"
gem 'hoptoad_notifier'

gem 'xebec'
gem 'capistrano', :group => :development
gem 'database_cleaner', :groups => [:development, :test]


after_bundler do
  generate "friendly_id"
  generate "formtastic:install"
end
