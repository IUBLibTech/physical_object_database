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

ActiveRecord::Schema.define(version: 20140513150746) do

  create_table "batches", force: true do |t|
    t.string   "identifier"
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bins", force: true do |t|
    t.integer  "batch_id"
    t.integer  "mdpi_barcode",              limit: 8
    t.integer  "picklist_specification_id", limit: 8
    t.string   "identifier",                          null: false
    t.text     "description"
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
  add_index "condition_status_templates", ["object_type", "name"], name: "index_cst_on_object_and_name", using: :btree

  create_table "condition_statuses", force: true do |t|
    t.integer  "condition_status_template_id"
    t.integer  "physical_object_id"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "bin_id"
  end

  add_index "condition_statuses", ["bin_id", "condition_status_template_id"], name: "index_cs_on_bin_and_cst", using: :btree
  add_index "condition_statuses", ["physical_object_id", "condition_status_template_id"], name: "index_cs_on_po_and_cst", using: :btree

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

  create_table "physical_objects", force: true do |t|
    t.integer  "bin_id"
    t.integer  "box_id",                limit: 8
    t.integer  "picklist_id",           limit: 8
    t.integer  "container_id",          limit: 8
    t.text     "title"
    t.string   "title_control_number"
    t.string   "home_location"
    t.string   "call_number"
    t.string   "shelf_location"
    t.integer  "iucat_barcode",         limit: 8
    t.string   "format"
    t.integer  "carrier_stream_index",            default: 0
    t.string   "collection_identifier"
    t.integer  "mdpi_barcode",          limit: 8
    t.string   "format_duration"
    t.string   "content_duration"
    t.boolean  "has_media"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "unit_id"
  end

  add_index "physical_objects", ["unit_id"], name: "index_physical_objects_on_unit_id", using: :btree

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

  create_table "units", force: true do |t|
    t.string   "abbreviation"
    t.string   "name"
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
  add_index "workflow_status_templates", ["object_type", "sequence_index"], name: "index_wst_on_object_type_and_sequence_index", using: :btree

  create_table "workflow_statuses", force: true do |t|
    t.integer  "workflow_status_template_id"
    t.integer  "physical_object_id"
    t.integer  "batch_id"
    t.integer  "bin_id"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "workflow_statuses", ["batch_id", "workflow_status_template_id"], name: "index_ws_on_batch_and_wst", using: :btree
  add_index "workflow_statuses", ["bin_id", "workflow_status_template_id"], name: "index_ws_on_bin_and_wst", using: :btree
  add_index "workflow_statuses", ["physical_object_id", "workflow_status_template_id"], name: "index_ws_on_po_and_wst", using: :btree

end
