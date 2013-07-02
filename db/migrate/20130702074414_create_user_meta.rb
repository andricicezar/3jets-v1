class CreateUserMeta < ActiveRecord::Migration
  def change
    create_table :user_meta do |t|
      t.integer :user_id,     :null => false
      t.string :key,          :null => false
      t.string :value

      t.timestamps
    end

  end
end
