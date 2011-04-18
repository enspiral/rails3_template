run "rm -Rf README public/index.html public/javascripts/* test app/views/layouts/*"

#gem 'haml', '>=3.0.4'
gem "haml-rails", ">= 0.2"
gem 'inherited_resources', '>=1.1.2'
gem 'will_paginate', '>=3.0.pre'
gem 'devise', '>=1.1.rc2'
gem "formtastic",'>= 1.1.0'
gem 'friendly_id', '~>3.0'
gem "compass", ">= 0.10.1"
gem 'hoptoad_notifier'

group :development do
  gem 'nifty-generators'
  gem 'capistrano'
  gem 'hpricot'
end

group :test do
  gem 'rspec', '>=2.0.0.alpha.11'
  gem 'rspec-rails', '>=2.0.0.alpha.11'
  gem 'steak', '>= 1.0.1'
  gem "capybara", "~> 0.3.8"
  gem 'machinist', '>= 2.0.0.beta2'
  gem "faker"                                                                                                                                                
  gem "accept_values_for"
  gem 'timecop'
end

application  <<-GENERATORS 
config.generators do |g|
  g.fixture_replacement :machinist
  g.orm :active_record
  g.template_engine :haml
  g.test_framework  :rspec, :fixture => true, :views => false
end
GENERATORS

run "bundle install"
generate "rspec:install"
generate "friendly_id"
generate "formtastic:install"
generate "machinist:install"
generate "devise:install"

run "gem install compass"
run "compass init --using blueprint --app rails"

run "rm public/stylesheets/*"

#TODO setup blueprints file
get "http://github.com/enspiral/rails3_template/raw/master/gitignore" ,".gitignore" 
get "http://github.com/enspiral/rails3_template/raw/master/screen.scss", "app/stylesheets/screen.scss"
get "http://github.com/enspiral/rails3_template/raw/master/application.html.haml", "app/views/layouts/application.html.haml"

create_file 'config/deploy.rb', <<-DEPLOY
set :application, "#{app_name}"
set :user, application
set :repository,  "git@github.com:enspiral/"#{app_name}.git"
set :scm, :git

set :deploy_to, "/home/\#{application}/staging"
set :deploy_via, :remote_cache
set :use_sudo, false
set :rails_env, :staging

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
  desc "bundle gems"
  task :bundle do
    run "cd #{release_path} && RAILS_ENV=#{rails_env} && bundle install #{shared_path}/gems/cache --deployment"
  end 
end

after "deploy:update_code" do
deploy.symlink_configs                                                                                                                     
  deploy.bundle                                                                                                                              
end
DEPLOY

run "capify ."
git :init
git :add => '.'
git :commit => '-am "Initial commit"'
 
puts "SUCCESS!"
