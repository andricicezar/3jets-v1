class CreateRelations < ActiveRecord::Migration
  def change
    create_table :relations do |t|
      t.integer :user_id
      t.integer :friend_id
      t.boolean :validated, :default => false
      t.timestamps
    end
  end
end
