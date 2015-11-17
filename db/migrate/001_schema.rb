class Schema < ActiveRecord::Migration
  def change
    create_table :achievements do |table|
      table.belongs_to :user, index: true
      table.column :user_string_id,        :string
      table.column :user_id,               :string
      table.column :instant,               :string
      table.column :template_id,           :string
      table.column :workout_id,            :string
    end
    create_table :workouts do |table|
      table.belongs_to :user, index: true
      table.column :user_string_id,        :string
      table.column :peloton_id,            :string
      table.column :user_id,               :string
      table.column :created,               :string
      table.column :start_time,            :string
      table.column :total_work,            :string
      table.column :ride_id,               :string
      table.column :total_zero_seconds,    :string
      table.column :is_qualifying,         :string
      table.column :end_time,              :string
      table.column :device_id,             :string
    end
    create_table :users do |table|
      table.column :id_from_redis,         :string
    end
  end
end