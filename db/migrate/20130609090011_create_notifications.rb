class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|

      t.string :title
      
      t.integer :user_id
      t.integer :friend_id

      t.string :accept_url
      t.string :decline_url

      t.timestamps
    end
  end
end
