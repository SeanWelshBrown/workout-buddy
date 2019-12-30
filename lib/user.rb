class User < ActiveRecord::Base
  has_many :user_exercises
  has_many :exercises, through => user_exercises
end