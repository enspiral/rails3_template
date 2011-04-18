# A basic setup of OmniAuth with a SessionsController to handle the request and callback phases.
puts  'Setting up  OmniAuth'

append_file 'Gemfile', "\n# Gems for omniauth\n"
gem 'omniauth'
gem "oa-oauth", :require => "omniauth/oauth"

create_file 'config/initializers/omniauth.rb', <<-DEPLOY
Rails.application.config.middleware.use OmniAuth::Builder do
    provider :twitter, 'CONSUMER_KEY', 'CONSUMER_SECRET'
    provider :facebook, 'APP_ID', 'APP_SECRET'
    provider :linked_in, 'CONSUMER_KEY', 'CONSUMER_SECRET'
end
DEPLOY

create_file 'app/controllers/'
after_bundler do
  file 'app/controllers/sessions_controller.rb', "class SessionsController < ApplicationController\n  def callback\n    auth # Do what you want with the auth hash!\n  end\n\n  def auth; request.env['omniauth.auth'] end\nend"
  route "match '/auth/:provider/callback', :to => 'sessions#callback'"
end

