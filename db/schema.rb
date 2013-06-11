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

ActiveRecord::Schema.define(version: 20130607094000) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "app_md5s", force: true do |t|
    t.string   "md5"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "app_md5s", ["md5"], name: "index_app_md5s_on_md5", using: :btree

  create_table "app_md5s_packages", id: false, force: true do |t|
    t.integer "app_md5_id"
    t.integer "package_id"
  end

  add_index "app_md5s_packages", ["app_md5_id"], name: "index_app_md5s_packages_on_app_md5_id", using: :btree
  add_index "app_md5s_packages", ["package_id"], name: "index_app_md5s_packages_on_package_id", using: :btree

  create_table "loaders", force: true do |t|
    t.string   "site_token"
    t.integer  "app_md5_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "loaders", ["app_md5_id"], name: "index_loaders_on_app_md5_id", using: :btree

  create_table "packages", force: true do |t|
    t.string   "name"
    t.string   "version"
    t.json     "dependencies"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "packages", ["name", "version"], name: "index_packages_on_name_and_version", unique: true, using: :btree
  add_index "packages", ["name"], name: "index_packages_on_name", using: :btree

end
