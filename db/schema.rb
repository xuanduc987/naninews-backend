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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160107020954) do

  create_table "api_tokens", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.string   "token",      limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "api_tokens", ["token"], name: "index_api_tokens_on_token", unique: true, using: :btree
  add_index "api_tokens", ["user_id"], name: "index_api_tokens_on_user_id", using: :btree

  create_table "posts", force: :cascade do |t|
    t.string   "url",         limit: 255
    t.string   "slug",        limit: 255
    t.string   "title",       limit: 255
    t.integer  "user_id",     limit: 4
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "votes_count", limit: 4,   default: 0, null: false
  end

  add_index "posts", ["slug"], name: "index_posts_on_slug", unique: true, using: :btree
  add_index "posts", ["url"], name: "index_posts_on_url", unique: true, using: :btree
  add_index "posts", ["user_id"], name: "index_posts_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.string   "email",           limit: 255
    t.string   "password_digest", limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

  create_table "votes", force: :cascade do |t|
    t.integer  "post_id",    limit: 4
    t.integer  "user_id",    limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "votes", ["post_id", "user_id"], name: "index_votes_on_post_id_and_user_id", unique: true, using: :btree
  add_index "votes", ["post_id"], name: "index_votes_on_post_id", using: :btree
  add_index "votes", ["user_id"], name: "index_votes_on_user_id", using: :btree

  add_foreign_key "api_tokens", "users"
  add_foreign_key "posts", "users"
  add_foreign_key "votes", "posts"
  add_foreign_key "votes", "users"
end
