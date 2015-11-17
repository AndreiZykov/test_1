class Workout < ActiveRecord::Base
  belongs_to :user
end
class User < ActiveRecord::Base
  has_many :workouts
  has_many :achievements
end
class Achievement < ActiveRecord::Base
  belongs_to :user
end