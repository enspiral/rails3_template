
gem "rspec-rails", :groups => [:development, :test]

inject_into_file "config/initializers/generators.rb", :after => "Rails.application.config.generators do |g|\n" do
  "    g.test_framework  :rspec, :fixture => true, :views => false\n"
end

after_bundler do
  generate 'rspec:install'
end


