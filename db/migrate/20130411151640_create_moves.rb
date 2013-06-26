class CreateMoves < ActiveRecord::Migration
  def change
    create_table :moves do |t|
      t.integer :user_id
      t.integer :game_id
      t.integer :top
      t.integer :left
      t.integer :hit
      t.timestamps
    end
  end
end
