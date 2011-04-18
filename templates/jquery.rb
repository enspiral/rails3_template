puts "setting up jquery"

gem 'jquery-rails'

run 'rm public/javascripts/rails.js'
puts "replacing Prototype with jQuery"
# "--ui" enables optional jQuery UI
after_bundler do
  generate "jquery:install --ui"
end


#inside "public/javascripts" do
#  get "https://github.com/rails/jquery-ujs/raw/master/src/rails.js", "rails.js"
#  get "http://code.jquery.com/jquery-1.4.4.js", "jquery/jquery.js"
#end
#
#application do
#  "\n    config.action_view.javascript_expansions[:defaults] = %w(jquery.min rails)\n"
#end
#
#gsub_file "config/application.rb", /# JavaScript.*\n/, ""
#gsub_file "config/application.rb", /# config\.action_view\.javascript.*\n/, ""
#
