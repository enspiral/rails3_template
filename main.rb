run "rm -Rf README public/index.html public/javascripts/* test app/views/layouts/*"

gem 'haml', '>=3.0.4'
gem 'inherited_resources', '>=1.1.2'
gem 'will_paginate', '>=3.0.pre'
gem 'devise', '>=1.1.rc2'
gem "formtastic",'>= 1.1.0'
gem 'friendly_id', '~>3.0'
gem "compass", ">= 0.10.1"

gem 'rspec', '>=2.0.0.alpha.11', :group => :test
gem 'rspec-rails', '>=2.0.0.alpha.11', :group => :test
#gem 'remarkable', '>=4.0.0.alpha4', :group => :test
#gem 'remarkable_activemodel', '>=4.0.0.alpha4', :group => :test
#gem 'remarkable_activerecord', '>=4.0.0.alpha4', :group => :test

gem 'cucumber', ">=0.6.3", :group => :cucumber
gem 'cucumber-rails', ">=0.3.2", :group => :cucumber
gem 'capybara', ">=0.3.6", :group => :cucumber
gem 'database_cleaner', ">=0.5.0", :group => :cucumber
gem 'spork', ">=0.8.4", :group => :cucumber
gem "pickle", :group => :cucumber

#gem 'inploy'

#gem 'rails3-generators', :git => "git://github.com/indirect/rails3-generators.git"

application  <<-GENERATORS 
config.generators do |g|
  g.template_engine :haml
  g.test_framework  :rspec, :fixture => true, :views => false
end
GENERATORS

run "bundle install"
generate "rspec:install"
generate "cucumber:install --capybara --rspec --spork"
generate "pickle:skeleton --path --email"
generate "friendly_id"
generate "formtastic:install"
generate "devise:install"

run "gem install compass"
run "compass init --using blueprint --app rails"

run "rm public/stylesheets/*"

#TODO setup blueprints file
get "http://github.com/enspiral/rails3_template/raw/master/gitignore" ,".gitignore" 
get "http://github.com/enspiral/rails3_template/raw/master/screen.scss", "app/stylesheets/screen.scss"
get "http://github.com/enspiral/rails3_template/raw/master/application.html.haml", "app/views/layouts/application.html.haml"

create_file 'config/deploy.rb', <<-DEPLOY
application = '
repository = ''
hosts = %w() 
set :application, "#{app_name}'"
set :user, application
set :repository,  "git@github.com:enspiral/"#{app_name}'.git"
set :scm, :git

set :deploy_to, "/home/\#{application}/production"
set :deploy_via, :remote_cache
set :use_sudo, false

role :web, "173.230.155.132"                 
role :app, "173.230.155.132"                  
role :db,  "173.230.155.132", :primary => true 

namespace :deploy do
  [:stop, :start, :restart].each do |task_name|
    task task_name, :roles => [:app] do
      run "cd \#{current_path} && touch tmp/restart.txt"
    end 
  end 
  task :symlink_configs do
    run %( cd \#{release_path} &&
      ln -nfs \#{shared_path}/config/database.yml \#{release_path}/config/database.yml
    )
  end 
end
before "deploy:restart", "deploy:symlink_configs"
DEPLOY

git :init
git :add => '.'
git :commit => '-am "Initial commit"'
 
puts "SUCCESS!"
