gem "compass"

after_bundler do
  run "compass init --using blueprint --app rails"
end
