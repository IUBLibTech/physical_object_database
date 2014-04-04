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

ActiveRecord::Schema.define(version: 20140403152552) do

  create_table "batches", force: true do |t|
    t.string   "identifier"
    t.string   "name"
    t.text     "description"
    t.string   "batch_status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bins", force: true do |t|
    t.integer  "batch_id"
    t.integer  "barcode",                   limit: 8
    t.integer  "picklist_specification_id", limit: 8
    t.string   "identifier",                          null: false
    t.text     "description"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "boxes", force: true do |t|
    t.integer  "bin_id",       limit: 8
    t.integer  "mdpi_barcode", limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cassette_tape_tms", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "compact_disc_tms", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "condition_status_templates", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "object_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "condition_status_templates", ["name"], name: "index_condition_status_templates_on_name", unique: true, using: :btree

  create_table "containers", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "digital_files", force: true do |t|
    t.integer  "physical_object_id", limit: 8
    t.string   "filename"
    t.string   "role"
    t.string   "format"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lp_tms", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "open_reel_tms", force: true do |t|
    t.string   "pack_deformation"
    t.string   "preservation_problem"
    t.string   "reel_size"
    t.string   "playback_speed"
    t.string   "track_configuration"
    t.string   "tape_thickness"
    t.string   "sound_field"
    t.string   "tape_stock_brand"
    t.string   "tape_base"
    t.date     "year_of_recording"
    t.string   "directions_recorded"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "physical_object_workflow_statuses", force: true do |t|
    t.integer  "physical_object_id",          limit: 8
    t.integer  "workflow_status_template_id", limit: 8
    t.string   "name"
    t.text     "notes"
    t.string   "object_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "physical_objects", force: true do |t|
    t.integer  "bin_id"
    t.integer  "box_id",               limit: 8
    t.integer  "picklist_id",          limit: 8
    t.integer  "container_id",         limit: 8
    t.integer  "memnon_barcode",       limit: 8
    t.integer  "iu_barcode",           limit: 8
    t.string   "shelf_number"
    t.string   "call_number"
    t.string   "title_control_number"
    t.text     "title"
    t.string   "format"
    t.string   "unit"
    t.string   "collection_id"
    t.string   "collection_name"
    t.string   "primary_location"
    t.string   "secondary_location"
    t.string   "composer_performer"
    t.string   "generation"
    t.string   "duration"
    t.string   "duration_type"
    t.integer  "carrier_stream_index",           default: 0
    t.boolean  "has_media"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "picklist_specifications", force: true do |t|
    t.string   "name"
    t.string   "format"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "picklists", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "picklists", ["name"], name: "index_picklists_on_name", unique: true, using: :btree

  create_table "technical_metadata", force: true do |t|
    t.integer  "as_technical_metadatum_id"
    t.string   "as_technical_metadatum_type"
    t.integer  "physical_object_id",          limit: 8
    t.integer  "picklist_specification_id",   limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "workflow_status_templates", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "sequence_index"
    t.string   "object_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "workflow_status_templates", ["name"], name: "index_workflow_status_templates_on_name", unique: true, using: :btree

  create_table "workflow_statuses", force: true do |t|
    t.integer  "workflow_status_template_id"
    t.integer  "condition_status_template_id"
    t.integer  "physical_object_id"
    t.integer  "batch_id"
    t.integer  "bin_id"
    t.text     "notes"
    t.integer  "order"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
