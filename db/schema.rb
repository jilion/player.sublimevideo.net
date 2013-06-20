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

  create_table "apps", force: true do |t|
    t.string   "token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "apps", ["token"], name: "index_apps_on_token", using: :btree

  create_table "apps_packages", id: false, force: true do |t|
    t.integer "app_id"
    t.integer "package_id"
  end

  add_index "apps_packages", ["app_id", "package_id"], name: "index_apps_packages_on_app_id_and_package_id", unique: true, using: :btree
  add_index "apps_packages", ["app_id"], name: "index_apps_packages_on_app_id", using: :btree
  add_index "apps_packages", ["package_id"], name: "index_apps_packages_on_package_id", using: :btree

  create_table "loaders", force: true do |t|
    t.integer  "app_id"
    t.string   "site_token"
    t.string   "stage"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "loaders", ["app_id", "site_token", "stage"], name: "index_loaders_on_app_id_and_site_token_and_stage", unique: true, using: :btree
  add_index "loaders", ["app_id"], name: "index_loaders_on_app_id", using: :btree
  add_index "loaders", ["site_token", "stage"], name: "index_loaders_on_site_token_and_stage", using: :btree
  add_index "loaders", ["site_token"], name: "index_loaders_on_site_token", using: :btree

  create_table "packages", force: true do |t|
    t.string   "name"
    t.string   "version"
    t.string   "zip"
    t.json     "dependencies"
    t.json     "settings"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "packages", ["name", "version"], name: "index_packages_on_name_and_version", unique: true, using: :btree
  add_index "packages", ["name"], name: "index_packages_on_name", using: :btree

end
