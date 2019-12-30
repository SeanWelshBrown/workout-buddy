class CreateExercises < ActiveRecord::Migration[5.2]
  def change
    create_table :exercises do |t|
      t.string :name
      t.string :exercise_type
      t.string :body_part
      t.string :muscle_group
      t.string :description
    end
  end
end
