create_file 'config/deploy.rb', <<-DEPLOY
require "bundler/capistrano"

set :application, "#{app_name}"
:set :user, application
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
    run "cd \#{release_path} && RAILS_ENV=\#{rails_env} && run  bundle install --gemfile \#{release_path}/Gemfile --path  \#{shared_path}/bundle --deployment  --without development test"
  end
end

after "deploy:update_code" do
deploy.symlink_configs
  deploy.bundle
end
DEPLOY
