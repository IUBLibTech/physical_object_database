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

ActiveRecord::Schema.define(version: 20160108161215) do

  create_table "analog_sound_disc_tms", force: true do |t|
    t.string   "diameter"
    t.string   "speed"
    t.string   "groove_size"
    t.string   "groove_orientation"
    t.string   "recording_method"
    t.string   "material"
    t.string   "substrate"
    t.string   "coating"
    t.string   "equalization"
    t.string   "country_of_origin"
    t.boolean  "delamination"
    t.boolean  "exudation"
    t.boolean  "oxidation"
    t.boolean  "cracked"
    t.boolean  "warped"
    t.boolean  "dirty"
    t.boolean  "scratched"
    t.boolean  "worn"
    t.boolean  "broken"
    t.boolean  "fungus"
    t.string   "label"
    t.string   "sound_field"
    t.string   "subtype"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "batches", force: true do |t|
    t.string   "identifier"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "workflow_status"
    t.integer  "workflow_index"
    t.string   "destination"
    t.string   "format"
  end

  add_index "batches", ["destination"], name: "index_batches_on_destination", using: :btree
  add_index "batches", ["workflow_status"], name: "index_batches_on_workflow_status", using: :btree

  create_table "betacam_tms", force: true do |t|
    t.string   "pack_deformation"
    t.boolean  "fungus"
    t.boolean  "soft_binder_syndrome"
    t.boolean  "other_contaminants"
    t.string   "cassette_size"
    t.string   "recording_standard"
    t.string   "format_duration"
    t.text     "tape_stock_brand"
    t.string   "image_format"
    t.string   "format_version"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "billable_physical_objects", force: true do |t|
    t.integer  "mdpi_barcode",  limit: 8
    t.datetime "delivery_date"
  end

  add_index "billable_physical_objects", ["mdpi_barcode"], name: "index_billable_physical_objects_on_mdpi_barcode", unique: true, using: :btree

  create_table "bins", force: true do |t|
    t.integer  "batch_id"
    t.integer  "mdpi_barcode",              limit: 8
    t.integer  "picklist_specification_id", limit: 8
    t.string   "identifier",                          null: false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "spreadsheet_id"
    t.string   "workflow_status"
    t.integer  "workflow_index"
    t.string   "destination"
    t.string   "format"
  end

  add_index "bins", ["batch_id"], name: "index_bins_on_batch_id", using: :btree
  add_index "bins", ["destination"], name: "index_bins_on_destination", using: :btree
  add_index "bins", ["picklist_specification_id"], name: "index_bins_on_picklist_specification_id", using: :btree
  add_index "bins", ["spreadsheet_id"], name: "index_bins_on_spreadsheet_id", using: :btree
  add_index "bins", ["workflow_index", "identifier"], name: "index_bins_on_workflow_index_and_identifier", using: :btree
  add_index "bins", ["workflow_status"], name: "index_bins_on_workflow_status", using: :btree

  create_table "boxes", force: true do |t|
    t.integer  "bin_id",         limit: 8
    t.integer  "mdpi_barcode",   limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "spreadsheet_id"
    t.boolean  "full",                     default: false
    t.text     "description"
    t.string   "format"
  end

  add_index "boxes", ["bin_id"], name: "index_boxes_on_bin_id", using: :btree
  add_index "boxes", ["spreadsheet_id"], name: "index_boxes_on_spreadsheet_id", using: :btree

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
    t.boolean  "blocks_packing", default: false
  end

  add_index "condition_status_templates", ["object_type", "name"], name: "index_cst_on_object_and_name", using: :btree

  create_table "condition_statuses", force: true do |t|
    t.integer  "condition_status_template_id"
    t.integer  "physical_object_id"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "bin_id"
    t.string   "user"
    t.boolean  "active"
  end

  add_index "condition_statuses", ["bin_id", "condition_status_template_id"], name: "index_cs_on_bin_and_cst", using: :btree
  add_index "condition_statuses", ["condition_status_template_id"], name: "index_condition_statuses_on_condition_status_template_id", using: :btree
  add_index "condition_statuses", ["physical_object_id", "condition_status_template_id"], name: "index_cs_on_po_and_cst", using: :btree
  add_index "condition_statuses", ["physical_object_id"], name: "index_condition_statuses_on_physical_object_id", using: :btree

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

  create_table "digital_file_provenances", force: true do |t|
    t.datetime "date_digitized"
    t.text     "comment"
    t.string   "created_by"
    t.string   "speed_used"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "digital_provenance_id", limit: 8
    t.string   "filename",                        null: false
    t.integer  "signal_chain_id",       limit: 8
    t.integer  "tape_fluxivity"
    t.string   "volume_units"
    t.string   "analog_output_voltage"
    t.integer  "peak"
    t.string   "stylus_size"
    t.string   "turnover"
    t.string   "rolloff"
  end

  add_index "digital_file_provenances", ["filename"], name: "index_digital_file_provenances_on_filename", unique: true, using: :btree
  add_index "digital_file_provenances", ["signal_chain_id"], name: "index_digital_file_provenances_on_signal_chain_id", using: :btree

  create_table "digital_provenances", force: true do |t|
    t.string   "digitizing_entity"
    t.datetime "date"
    t.text     "comments"
    t.datetime "cleaning_date"
    t.datetime "baking"
    t.boolean  "repaired"
    t.integer  "physical_object_id",    limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "cleaning_comment"
    t.text     "xml",                   limit: 2147483647
    t.string   "duration"
    t.text     "batch_processing_flag"
  end

  add_index "digital_provenances", ["physical_object_id"], name: "index_digital_provenances_on_physical_object_id", using: :btree

  create_table "digital_statuses", force: true do |t|
    t.integer  "physical_object_id"
    t.integer  "physical_object_mdpi_barcode", limit: 8
    t.string   "state"
    t.text     "message"
    t.boolean  "accepted"
    t.boolean  "attention"
    t.text     "decided"
    t.text     "options"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "decided_manually",                       default: false
  end

  add_index "digital_statuses", ["created_at", "state", "physical_object_id"], name: "quality_control_staging", using: :btree
  add_index "digital_statuses", ["physical_object_id"], name: "index_digital_statuses_on_physical_object_id", using: :btree

  create_table "doFiles", id: false, force: true do |t|
    t.string  "mdpiBarcode", limit: 14, null: false
    t.integer "partNumber",  limit: 1
    t.boolean "isMaster"
    t.string  "fileUsage"
    t.string  "md5",         limit: 32
    t.integer "size",        limit: 8
    t.float   "duration",    limit: 24
  end

  add_index "doFiles", ["mdpiBarcode", "partNumber"], name: "mdpiBarcode", using: :btree

  create_table "doObjects", primary_key: "mdpiBarcode", force: true do |t|
    t.string   "digitizingEntity"
    t.string   "objectType"
    t.datetime "acceptTime"
    t.datetime "bagTime"
    t.integer  "size",             limit: 8
  end

  create_table "doParts", id: false, force: true do |t|
    t.string  "mdpiBarcode", limit: 14, null: false
    t.integer "partNumber",  limit: 1,  null: false
    t.boolean "vendorQC"
  end

  create_table "eight_millimeter_video_tms", force: true do |t|
    t.string   "pack_deformation"
    t.boolean  "fungus"
    t.boolean  "soft_binder_syndrome"
    t.boolean  "other_contaminants"
    t.string   "recording_standard"
    t.string   "format_duration"
    t.string   "tape_stock_brand"
    t.string   "image_format"
    t.string   "format_version"
    t.string   "playback_speed"
    t.string   "binder_system"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "group_keys", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "group_total"
    t.string   "avalon_url"
  end

  create_table "machines", force: true do |t|
    t.string   "category"
    t.string   "serial"
    t.string   "manufacturer"
    t.string   "model"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "memnon_invoice_submissions", force: true do |t|
    t.string   "filename"
    t.datetime "submission_date"
    t.boolean  "successful_validation"
    t.integer  "validation_completion_percent"
    t.boolean  "bad_headers",                                      default: false
    t.text     "other_error",                   limit: 2147483647
    t.text     "problems_by_row",               limit: 2147483647
  end

  create_table "messages", force: true do |t|
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notes", force: true do |t|
    t.integer  "physical_object_id"
    t.text     "body"
    t.string   "user"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "export"
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
    t.integer  "calculated_directions_recorded"
    t.integer  "directions_recorded"
  end

  create_table "physical_objects", force: true do |t|
    t.integer  "bin_id"
    t.integer  "box_id",                    limit: 8
    t.integer  "picklist_id",               limit: 8
    t.integer  "container_id",              limit: 8
    t.text     "title"
    t.string   "title_control_number"
    t.string   "home_location"
    t.string   "call_number"
    t.string   "iucat_barcode"
    t.string   "format"
    t.string   "collection_identifier"
    t.integer  "mdpi_barcode",              limit: 8
    t.string   "format_duration"
    t.boolean  "has_ephemera"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "author"
    t.string   "catalog_key"
    t.string   "collection_name"
    t.string   "generation"
    t.string   "oclc_number"
    t.boolean  "other_copies"
    t.string   "year"
    t.integer  "unit_id"
    t.integer  "group_key_id"
    t.integer  "group_position"
    t.boolean  "ephemera_returned"
    t.integer  "spreadsheet_id"
    t.string   "workflow_status"
    t.integer  "workflow_index"
    t.boolean  "staging_requested",                   default: false
    t.boolean  "staged",                              default: false
    t.datetime "digital_start"
    t.datetime "staging_request_timestamp"
    t.boolean  "audio"
    t.boolean  "video"
    t.boolean  "memnon_qc_completed"
    t.boolean  "billed",                              default: false
    t.datetime "date_billed"
    t.string   "spread_sheet_filename"
  end

  add_index "physical_objects", ["bin_id"], name: "index_physical_objects_on_bin_id", using: :btree
  add_index "physical_objects", ["box_id"], name: "index_physical_objects_on_box_id", using: :btree
  add_index "physical_objects", ["container_id"], name: "index_physical_objects_on_container_id", using: :btree
  add_index "physical_objects", ["group_key_id"], name: "index_physical_objects_on_group_key_id", using: :btree
  add_index "physical_objects", ["picklist_id", "group_key_id", "group_position", "id"], name: "index_physical_objects_on_packing_sort", using: :btree
  add_index "physical_objects", ["spread_sheet_filename"], name: "index_physical_objects_on_spread_sheet_filename", using: :btree
  add_index "physical_objects", ["spreadsheet_id"], name: "index_physical_objects_on_spreadsheet_id", using: :btree
  add_index "physical_objects", ["unit_id"], name: "index_physical_objects_on_unit_id", using: :btree
  add_index "physical_objects", ["workflow_status"], name: "index_physical_objects_on_workflow_status", using: :btree

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
    t.string   "destination"
    t.boolean  "complete",    default: false
  end

  add_index "picklists", ["destination"], name: "index_picklists_on_destination", using: :btree
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

  add_index "preservation_problems", ["open_reel_tm_id"], name: "index_preservation_problems_on_open_reel_tm_id", using: :btree

  create_table "processing_steps", force: true do |t|
    t.integer  "signal_chain_id"
    t.integer  "machine_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "processing_steps", ["machine_id"], name: "index_processing_steps_on_machine_id", using: :btree
  add_index "processing_steps", ["signal_chain_id"], name: "index_processing_steps_on_signal_chain_id", using: :btree

  create_table "signal_chains", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "spreadsheets", force: true do |t|
    t.string   "filename"
    t.text     "note"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "spreadsheets", ["filename"], name: "index_spreadsheets_on_filename", unique: true, using: :btree

  create_table "technical_metadata", force: true do |t|
    t.integer  "actable_id"
    t.string   "actable_type"
    t.integer  "physical_object_id",        limit: 8
    t.integer  "picklist_specification_id", limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "technical_metadata", ["actable_id", "actable_type"], name: "technical_metadata_as_technical_metadatum_index", using: :btree
  add_index "technical_metadata", ["physical_object_id"], name: "index_technical_metadata_on_physical_object_id", using: :btree
  add_index "technical_metadata", ["picklist_specification_id"], name: "index_technical_metadata_on_picklist_specification_id", using: :btree

  create_table "umatic_video_tms", force: true do |t|
    t.string   "pack_deformation"
    t.boolean  "fungus"
    t.boolean  "soft_binder_syndrome"
    t.boolean  "other_contaminants"
    t.string   "recording_standard"
    t.string   "format_duration"
    t.string   "size"
    t.string   "tape_stock_brand"
    t.string   "image_format"
    t.string   "format_version"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "units", force: true do |t|
    t.string   "abbreviation"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "institution"
    t.string   "campus"
  end

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "username"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "smart_team_user"
    t.boolean  "smart_team_admin"
    t.boolean  "qc_user"
    t.boolean  "qc_admin"
    t.boolean  "web_admin"
    t.boolean  "engineer"
  end

  create_table "workflow_status_templates", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "sequence_index"
    t.string   "object_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "workflow_status_templates", ["object_type", "name"], name: "index_wst_on_object_and_name", using: :btree
  add_index "workflow_status_templates", ["object_type", "sequence_index"], name: "index_wst_on_object_type_and_sequence_index", using: :btree

  create_table "workflow_statuses", force: true do |t|
    t.integer  "workflow_status_template_id"
    t.integer  "physical_object_id"
    t.integer  "batch_id"
    t.integer  "bin_id"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "user"
    t.boolean  "has_ephemera"
    t.boolean  "ephemera_returned"
    t.boolean  "ephemera_okay"
  end

  add_index "workflow_statuses", ["batch_id", "workflow_status_template_id"], name: "index_ws_on_batch_and_wst", using: :btree
  add_index "workflow_statuses", ["bin_id", "workflow_status_template_id"], name: "index_ws_on_bin_and_wst", using: :btree
  add_index "workflow_statuses", ["physical_object_id", "workflow_status_template_id"], name: "index_ws_on_po_and_wst", using: :btree

end
