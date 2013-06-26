class CreateResults < ActiveRecord::Migration
  def change
    create_table :results do |t|
      t.integer :user_id
      t.integer :game_id
      t.integer :result
      t.timestamps
    end
  end
end
