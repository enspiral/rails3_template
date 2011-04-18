run "rm -Rf README public/index.html public/javascripts/* test app/views/layouts/*"

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
GENERATORS

run "bundle install"
generate "rspec:install"
generate "friendly_id"
generate "formtastic:install"
generate "machinist:install"
generate "devise:install"

#----------------------------------------------------------------------------
# Remove the usual cruft
#----------------------------------------------------------------------------
puts "removing unneeded files..."

#run 'rm config/database.yml' #too destructive??
run 'rm public/index.html'
run 'rm public/favicon.ico'
run 'rm public/images/rails.png'
run 'rm README'
run 'touch README'

#----------------------------------------------------------------------------
# Set up the gemfile and install all gems needed for the rest of the templates
#----------------------------------------------------------------------------

puts "running bundle install, this might take a little bit"
run 'bundle install'
#puts "Running after Bundler callbacks."
#@after_blocks.each{|b| b.call}

puts "placing files from the repo into your app"
#TODO setup blueprints file
get "https://github.com/enspiral/rails3_template/raw/master/gitignore", ".gitignore"
get "https://github.com/enspiral/rails3_template/raw/master/screen.scss", "app/stylesheets/screen.scss"
get "https://github.com/enspiral/rails3_template/raw/master/application.html.haml", "app/views/layouts/application.html.haml"

puts "capify"
run "capify ."

puts "git"
git :init
git :add => '.'
git :commit => '-am "Initial commit"'

puts "SUCCESS!"

#@remote_template_path = "https://github.com/enspiral/rails3_template/raw/master"
#@local_template_path = File.expand_path(File.join(File.dirname(__FILE__)))
#@template_path = @local_template_path
#puts @local_template_path

#apply_template "standard_gems"
#apply_template "haml"
#apply_template "rspec"
#apply_template 'jquery'
#apply_template 'steak'
#apply_template 'deploy'
#apply_template 'compass'
#apply_template 'devise'
#apply_template 'omniauth'
#def apply_template(name)

#  local_file_name = "#{@local_template_path}/templates/#{name}.rb"

  # This is a temporary hack to only use local paths since remote paths are currently broken in rails3.
  # apply local_file_name
  # return

#   if File.exist?(local_file_name)
#     apply local_file_name
#   else
#     apply "#{remote_template_path}/templates/#{name}rb"
#   end
#end

#def agnostic_copy(from_file, to_file)

#  if @template_path[0..6] == "http://" || @template_path[0..7] == "https://"
#    run "curl -L #{@template_path}/#{from_file} > #{to_file}"
#  else
#    copy_file "#{@template_path}/#{from_file}", "#{to_file}"
#  end
#end

#@after_blocks = []
#def after_bundler(&block); @after_blocks << block; end
