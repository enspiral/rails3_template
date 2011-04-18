puts "setting up steak"
gem 'steak', :groups => [:development, :test]
gem 'capybara', :groups => [:development, :test]

after_bundler do
  generate 'steak:install'
end
