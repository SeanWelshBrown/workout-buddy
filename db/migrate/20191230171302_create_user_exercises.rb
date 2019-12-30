class CreateUserExercises < ActiveRecord::Migration[5.2]
  def change
    create_table :user_exercises do |t|
      t.integer :user_id
      t.integer :exercise_id
    end
  end
end
