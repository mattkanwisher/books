# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20080719210956) do

  create_table "books", :force => true do |t|
    t.string "title"
    t.string "asin"
    t.string "image_url"
    t.string "amz_purchase_url"
    t.string "author"
    t.string "url_key"
    t.integer "views", :default => 0
    t.integer "last_sent_notification", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  
  
  create_table "notifications", :force => true do |t|
    t.string "email"
    t.integer "book_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "recommends", :force => true do |t|
    t.integer   "book_id"
    t.integer   "user_id"
    t.integer   "comment_id"
  end
  
  create_table "spoilers", :force => true do |t|
    t.integer   "book_id"
    t.integer  "user_id"
    t.integer   "comment_id"
  end

  
  create_table "comments", :force => true do |t|
    t.integer   "book_id"
    t.text   "body"
    t.string   "name"
    t.string   "email"  
    t.integer  "user_id"
    t.integer "spoilercount", :default => 0
    t.integer "recommendcount", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  
  create_table "users", :force => true do |t|
    t.column :login,                     :string
    t.column :email,                     :string
    t.column :crypted_password,          :string, :limit => 40
    t.column :salt,                      :string, :limit => 40
    t.column :created_at,                :datetime
    t.column :updated_at,                :datetime
    t.column :remember_token,            :string
    t.column :remember_token_expires_at, :datetime
  end
  

end
