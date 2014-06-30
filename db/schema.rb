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

ActiveRecord::Schema.define(version: 20140630154420) do

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

  create_table "cdr_tms", force: true do |t|
    t.string   "damage"
    t.boolean  "fungus"
    t.boolean  "other_contaminants"
    t.boolean  "breakdown_of_materials"
    t.string   "format_duration"
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

  create_table "dat_tms", force: true do |t|
    t.boolean  "sample_rate_32k"
    t.boolean  "sample_rate_44_1_k"
    t.boolean  "sample_rate_48k"
    t.boolean  "sample_rate_96k"
    t.string   "format_duration"
    t.string   "tape_stock_brand"
    t.boolean  "fungus"
    t.boolean  "soft_binder_syndrome"
    t.boolean  "other_contaminants"
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

  create_table "group_keys", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "physical_objects_count", default: 0, null: false
  end

  create_table "lp_tms", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notes", force: true do |t|
    t.integer  "physical_object_id"
    t.text     "body"
    t.string   "user"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notes", ["physical_object_id"], name: "index_notes_on_physical_object_id", using: :btree

  create_table "open_reel_tms", force: true do |t|
    t.string   "pack_deformation"
    t.string   "reel_size"
    t.string   "tape_stock_brand"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "vinegar_syndrome"
    t.boolean  "fungus"
    t.boolean  "soft_binder_syndrome"
    t.boolean  "other_contaminants"
    t.boolean  "zero_point9375_ips"
    t.boolean  "one_point875_ips"
    t.boolean  "three_point75_ips"
    t.boolean  "seven_point5_ips"
    t.boolean  "fifteen_ips"
    t.boolean  "thirty_ips"
    t.boolean  "full_track"
    t.boolean  "half_track"
    t.boolean  "quarter_track"
    t.boolean  "unknown_track"
    t.boolean  "zero_point5_mils"
    t.boolean  "one_mils"
    t.boolean  "one_point5_mils"
    t.boolean  "mono"
    t.boolean  "stereo"
    t.boolean  "unknown_sound_field"
    t.boolean  "acetate_base"
    t.boolean  "polyester_base"
    t.boolean  "pvc_base"
    t.boolean  "paper_base"
    t.boolean  "unknown_playback_speed"
    t.boolean  "one_direction"
    t.boolean  "two_directions"
    t.boolean  "unknown_direction"
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
    t.string   "iucat_barcode"
    t.string   "format"
    t.string   "collection_identifier"
    t.integer  "mdpi_barcode",          limit: 8
    t.string   "format_duration"
    t.boolean  "has_ephemera"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "unit_id"
    t.string   "author"
    t.string   "catalog_key"
    t.string   "collection_name"
    t.string   "generation"
    t.string   "oclc_number"
    t.boolean  "other_copies"
    t.string   "year"
    t.integer  "group_key_id"
    t.integer  "group_position"
  end

  add_index "physical_objects", ["group_key_id"], name: "index_physical_objects_on_group_key_id", using: :btree
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

  create_table "preservation_problems", force: true do |t|
    t.integer  "open_reel_tm_id"
    t.boolean  "vinegar_odor"
    t.boolean  "fungus"
    t.boolean  "soft_binder_syndrome"
    t.boolean  "other_contaminants"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
