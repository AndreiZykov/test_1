require 'redis'
require 'active_record'
require 'sqlite3'

require_relative "models"

class CustomMethods

  def self.show_results
    @user = User.joins(:workouts).group("workouts.user_id").order("count(workouts.user_id) desc").first(10)

    puts "\n\ntop 10 by number of workouts"

    @user.each do |user|
      puts " user_id \"#{user.id_from_redis}\" has - #{user.workouts.count.to_s} workouts"
    end

    puts "\ntop 10 by number of achievements"

    @user = User.joins(:achievements).group("achievements.user_id").order("count(achievements.user_id) desc").first(10)

    @user.each do |user|
      puts " user_id \"#{user.id_from_redis}\" has - #{user.achievements.count.to_s} achievements"
    end
  end

  def self.kill_all_items
    User.all.each do |user|
      user.destroy.save
    end

    Workout.all.each do |workout|
      workout.destroy.save
    end

    Achievement.all.each do |achievement|
      achievement.destroy.save
    end
    puts "DB is empty now!"
  end


  def self.parse_redis_db

    create_workouts_and_achievement

    create_user

    set_associations

  end



  private

  def self.set_associations
    count_ac = Workout.all.count
    i = 0
    Workout.all.each do |workout|
      @user = User.find_by id_from_redis: workout.user_string_id
      workout.user = @user
      workout.save
      puts "#{i}/#{count_ac}"
      i = i+1
    end

    count_ac = Achievement.all.count
    i = 0
    Achievement.all.each do |achievement|
      @user = User.find_by id_from_redis: achievement.user_string_id
      achievement.user = @user
      achievement.save
      puts "#{i}/#{count_ac}"
      i = i+1
    end
  end

  def self.create_workouts_and_achievement

    redis = Redis.new(host: "localhost",
                      port: 6379,
                      db: 2)

    keys_for_achievements = redis.keys("achievement:*")

    count_of_keys_for_achievements = keys_for_achievements.count

    keys_for_achievements.count.times do |i|
      @item = redis.hscan(keys_for_achievements[i], 0)
      user_id_array  = @item.last[0]
      create_achievement(@item[1])
      puts "#{i}/#{count_of_keys_for_achievements}"
    end

    keys_for_workouts = redis.keys("workout:*")

    count_of_keys_for_workouts = keys_for_workouts.count

    keys_for_workouts.count.times do |i|
      @item = redis.hscan(keys_for_workouts[i], 0)
      user_id_array  = @item.last[1]
      create_workout(@item[1])
      puts "#{i}/#{count_of_keys_for_workouts}"
    end

  end

  def self.create_user
    user_id = Array.new

    Workout.all.each do |workout|
      user_id << workout.user_string_id
    end

    Achievement.all.each do |achievement|
      user_id << achievement.user_string_id
    end

    user_id = user_id.uniq

    puts user_id.count

    user_id.each do |user_id_string|
      User.new(id_from_redis: user_id_string).save
    end
  end

  def self.data_array_to_hash(data)
    hash_for_return = Hash.new
    data.each do |small_array|
      hash_for_return[small_array.first] = small_array.last
    end
    hash_for_return["user_string_id"] = hash_for_return["user_id"]
    hash_for_return
  end

  def self.create_achievement(data)
    Achievement.new(
        data_array_to_hash(data)
    ).save
  end

  def self.create_workout(data)
    Workout.new(
        data_array_to_hash(data)
    ).save
  end
end