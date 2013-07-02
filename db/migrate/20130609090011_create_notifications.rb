class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :notf_type

      t.string :title
      t.string :special_class

      t.integer :user_id
      t.integer :friend_id

      t.string :accept_url
      t.string :view_url

      t.timestamps
    end
  end
end
