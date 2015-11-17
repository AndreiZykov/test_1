require 'active_record'
require 'sqlite3'
require 'yaml'
require 'redis'
require_relative "custom_methods"

require_relative "models"

configuration = YAML::load(IO.read('./config/database.yml'))

ActiveRecord::Base.establish_connection(configuration['development'])

## CustomMethods.kill_all_items

## CustomMethods.parse_redis_db

## CustomMethods.set_associations

# puts User.all.count.to_s
# puts Workout.all.count.to_s
# puts Achievement.all.count.to_s

CustomMethods.show_results
