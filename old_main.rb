#Too destructive... run "rm -Rf README public/index.html public/javascripts/* test app/views/layouts/*"


#----------------------------------------------------------------------------
# Remove the usual cruft
#----------------------------------------------------------------------------
puts "removing unneeded files..."
run 'rm config/database.yml' #too destructive??
run 'rm public/index.html'
run 'rm public/favicon.ico'
run 'rm public/images/rails.png'
run 'rm README'
run 'touch README'

puts "banning spiders from your site by changing robots.txt..."
gsub_file 'public/robots.txt', /# User-Agent/, 'User-Agent'
gsub_file 'public/robots.txt', /# Disallow/, 'Disallow'


#----------------------------------------------------------------------------
# Set up gems
#-------------------------------------------------------------------

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


#----------------------------------------------------------------------------
# Setup the various gems
#----------------------------------------------------------------------------


# Jquery

run 'rm public/javascripts/rails.js'
puts "replacing Prototype with jQuery"
# "--ui" enables optional jQuery UI
run 'rails generate jquery:install --ui'


# HAML

application <<-GENERATORS
config.generators do |g|
  g.template_engine :haml
  g.test_framework  :rspec, :fixture => true, :views => false
end
GENERATORS


#----------------------------------------------------------------------------
# Set up Devise
#----------------------------------------------------------------------------

puts "creating 'config/initializers/devise.rb' Devise configuration file..."
run 'rails generate devise:install'
run 'rails generate devise:views'

puts "modifying environment configuration files for Devise..."
gsub_file 'config/environments/development.rb', /# Don't care if the mailer can't send/, '### ActionMailer Config'
gsub_file 'config/environments/development.rb', /config.action_mailer.raise_delivery_errors = false/ do
  <<-RUBY
config.action_mailer.default_url_options = { :host => 'localhost:3000' }
  # A dummy setup for development - no deliveries, but logged
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = false
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default :charset => "utf-8"
  RUBY
end
gsub_file 'config/environments/production.rb', /config.i18n.fallbacks = true/ do
  <<-RUBY
config.i18n.fallbacks = true

  config.action_mailer.default_url_options = { :host => 'yourhost.com' }
  ### ActionMailer Config
  # Setup for production - deliveries, no errors raised
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default :charset => "utf-8"
  RUBY
end

puts "creating a User model and modifying routes for Devise..."
run 'rails generate devise User'

puts "adding a 'name' attribute to the User model"
class AddAdminRole < ActiveRecord::Migration
  def self.up
      add_column :users, :name,  :string
      add_column :users, :admin, :boolean, :default => false
    end

    def self.down
      remove_column :users, :admin
      remove_column :users, :name
    end

end
gsub_file 'app/models/user.rb', /end/ do
  <<-RUBY

  validates_presence_of :name
  validates_uniqueness_of :name, :email, :case_sensitive => false
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable,
         #:registerable,
         #:recoverable,
         :rememberable,
         #:trackable,
         :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me , :admin

end
  RUBY
end

#----------------------------------------------------------------------------
# Modify Devise views
#----------------------------------------------------------------------------
puts "modifying the default Devise user registration to add 'name'..."

inject_into_file "app/views/devise/registrations/edit.html.haml", :after => "= devise_error_messages!\n" do
  <<-RUBY
  %p
    = f.label :name
    %br/
    = f.text_field :name
  RUBY
end


inject_into_file "app/views/devise/registrations/new.html.haml", :after => "= devise_error_messages!\n" do
  <<-RUBY
  %p
    = f.label :name
    %br/
    = f.text_field :name
  RUBY
end






#----------------------------------------------------------------------------
# Create a home page
#----------------------------------------------------------------------------
puts "create a home controller and view"
generate(:controller, "home index")
gsub_file 'config/routes.rb', /get \"home\/index\"/, 'root :to => "home#index"'

puts "set up a simple demonstration of Devise"
gsub_file 'app/controllers/home_controller.rb', /def index/ do
<<-RUBY
def index
    @users = User.all
RUBY
end


  run 'rm app/views/home/index.html.haml'
  # we have to use single-quote-style-heredoc to avoid interpolation
  create_file 'app/views/home/index.html.haml' do
<<-'FILE'
- @users.each do |user|
  %p User: #{link_to user.name, user}
FILE
  end

#----------------------------------------------------------------------------
# Create a users page
#----------------------------------------------------------------------------
generate(:controller, "users show")
gsub_file 'config/routes.rb', /get \"users\/show\"/, '#get \"users\/show\"'
gsub_file 'config/routes.rb', /devise_for :users/ do
<<-RUBY
devise_for :users
  resources :users, :only => :show
RUBY
end

gsub_file 'app/controllers/users_controller.rb', /def show/ do
<<-RUBY
before_filter :authenticate_user!

  def show
    @user = User.find(params[:id])
RUBY
end


  run 'rm app/views/users/show.html.haml'
  # we have to use single-quote-style-heredoc to avoid interpolation
  create_file 'app/views/users/show.html.haml' do <<-'FILE'
%p
  User: #{@user.name}
  FILE
  end



  create_file "app/views/devise/menu/_login_items.html.haml" do <<-'FILE'
- if user_signed_in?
  %li
    = link_to('Logout', destroy_user_session_path)
- else
  %li
    = link_to('Login', new_user_session_path)
  FILE
  end



  create_file "app/views/devise/menu/_registration_items.html.haml" do <<-'FILE'
- if user_signed_in?
  %li
    = link_to('Edit account', edit_user_registration_path)
- else
  %li
    = link_to('Sign up', new_user_registration_path)
  FILE
  end


#----------------------------------------------------------------------------
# Generate Application Layout
#----------------------------------------------------------------------------
if haml_flag
  run 'rm app/views/layouts/application.html.erb'
  create_file 'app/views/layouts/application.html.haml' do <<-FILE
!!!
%html
  %head
    %title Testapp
    = stylesheet_link_tag :all
    = javascript_include_tag :defaults
    = csrf_meta_tag
  %body
    %ul.hmenu
      = render 'devise/menu/registration_items'
      = render 'devise/menu/login_items'
    %p{:style => "color: green"}= notice
    %p{:style => "color: red"}= alert
    = yield
FILE
  end
else
  inject_into_file 'app/views/layouts/application.html.erb', :after => "<body>\n" do
  <<-RUBY
<ul class="hmenu">
  <%= render 'devise/menu/registration_items' %>
  <%= render 'devise/menu/login_items' %>
</ul>
<p style="color: green"><%= notice %></p>
<p style="color: red"><%= alert %></p>
RUBY
  end
end








#----------------------------------------------------------------------------
# Configure
#----------------------------------------------------------------------------


run "bundle install"
generate "rspec:install"
#generate "cucumber:install --capybara --rspec --spork"
#generate "pickle:skeleton --path --email"
generate "friendly_id"
generate "formtastic:install"
generate "devise:install"

run "gem install compass"
run "compass init --using blueprint --app rails"

run "rm public/stylesheets/*"

#TODO setup blueprints file
get "https://github.com/enspiral/rails3_template/raw/master/gitignore", ".gitignore"
get "https://github.com/enspiral/rails3_template/raw/master/screen.scss", "app/stylesheets/screen.scss"
get "https://github.com/enspiral/rails3_template/raw/master/application.html.haml", "app/views/layouts/application.html.haml"


run "capify ."
git :init
git :add => '.'
git :commit => '-am "Initial commit"'

puts "SUCCESS!"
