class CreateAirplanes < ActiveRecord::Migration
  def change
    create_table :airplanes do |t|
      t.integer :user_id
      t.integer :game_id
      t.integer :shape
      t.integer :top
      t.integer :left
      t.integer :rotation
      t.timestamps
    end
  end
end
