class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.integer :num_players, :default => 0
      t.integer :fst_user, :default => 0
      t.integer :scd_user, :default => 0

      t.boolean :finished, :default => false

      t.boolean :validated, :default => true
      t.boolean :countable, :default => true 

      t.timestamps
    end
  end
end
