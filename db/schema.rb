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

ActiveRecord::Schema.define(version: 20140217180712) do

  create_table "physical_objects", force: true do |t|
    t.integer  "bin_id"
    t.integer  "box_id",                limit: 8
    t.integer  "picklist_id",           limit: 8
    t.integer  "container_id",          limit: 8
    t.text     "title"
    t.string   "title_control_number"
    t.string   "home_location"
    t.string   "call_number"
    t.integer  "iucat_barcode"
    t.string   "format"
    t.string   "collection_identifier"
    t.integer  "mdpi_barcode",          limit: 8
    t.string   "format_duration"
    t.boolean  "has_ephemira"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "carrier_stream_index"
    t.string   "unit"
    t.string   "content_duration"
    t.string   "shelf_location"
  end

end
