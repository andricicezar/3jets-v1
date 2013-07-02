class CreateAchievements < ActiveRecord::Migration
  def change
    create_table :achievements do |t|
      t.string :name
      t.string :description
      t.string :icon

      t.string  :key_watched
      t.integer :min_value,    :default => 0

      t.integer :award_points, :default => 0
      t.string  :award_icon
      t.timestamps
    end
  end
end
