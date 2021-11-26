# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative "config/application"

Rails.application.load_tasks

namespace :db_schema do
  task :apply do
    system("ridgepole --config config/database.yml --env #{ENV['RAILS_ENV'] || 'development'} --apply -f db/Schemafile")
  end
end
