gem 'haml'
gem 'haml-rails', :group => :development

inject_into_file "config/initializers/generators.rb", :after => "Rails.application.config.generators do |g|\n" do
  "    g.template_engine :haml\n"
end

