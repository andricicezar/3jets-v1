# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130702074414) do

  create_table "active_admin_comments", :force => true do |t|
    t.string   "resource_id",   :null => false
    t.string   "resource_type", :null => false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_admin_notes_on_resource_type_and_resource_id"

  create_table "admin_users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "admin_users", ["email"], :name => "index_admin_users_on_email", :unique => true
  add_index "admin_users", ["reset_password_token"], :name => "index_admin_users_on_reset_password_token", :unique => true

  create_table "airplanes", :force => true do |t|
    t.integer  "user_id"
    t.integer  "game_id"
    t.integer  "shape"
    t.integer  "top"
    t.integer  "left"
    t.integer  "rotation"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "game_users", :force => true do |t|
    t.integer  "game_id"
    t.integer  "user_id"
    t.integer  "num_airplanes", :default => 3
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  create_table "games", :force => true do |t|
    t.integer  "num_players", :default => 0
    t.integer  "fst_user",    :default => 0
    t.integer  "scd_user",    :default => 0
    t.boolean  "finished",    :default => false
    t.boolean  "validated",   :default => true
    t.boolean  "countable",   :default => true
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  create_table "moves", :force => true do |t|
    t.integer  "user_id"
    t.integer  "game_id"
    t.integer  "top"
    t.integer  "left"
    t.integer  "hit"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "notifications", :force => true do |t|
    t.integer  "notf_type"
    t.string   "title"
    t.string   "special_class"
    t.integer  "user_id"
    t.integer  "friend_id"
    t.string   "accept_url"
    t.string   "view_url"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "relations", :force => true do |t|
    t.integer  "user_id"
    t.integer  "friend_id"
    t.boolean  "validated",  :default => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "results", :force => true do |t|
    t.integer  "user_id"
    t.integer  "game_id"
    t.integer  "result"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "user_meta", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.string   "key",        :null => false
    t.string   "value"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => ""
    t.string   "encrypted_password",     :default => "",    :null => false
    t.integer  "elo",                    :default => 1400
    t.string   "nickname",                                  :null => false
    t.boolean  "deleted",                :default => false
    t.boolean  "veteran",                :default => false
    t.string   "facebook_uid",           :default => "0"
    t.string   "twitter_uid",            :default => "0"
    t.string   "google_uid",             :default => "0"
    t.string   "image_link",             :default => ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["nickname"], :name => "index_users_on_nickname", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
