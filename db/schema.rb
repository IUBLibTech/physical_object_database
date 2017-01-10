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

ActiveRecord::Schema.define(version: 20161219221806) do

  create_table "analog_sound_disc_tms", force: :cascade do |t|
    t.string   "diameter",           limit: 255
    t.string   "speed",              limit: 255
    t.string   "groove_size",        limit: 255
    t.string   "groove_orientation", limit: 255
    t.string   "recording_method",   limit: 255
    t.string   "material",           limit: 255
    t.string   "substrate",          limit: 255
    t.string   "coating",            limit: 255
    t.string   "equalization",       limit: 255
    t.string   "country_of_origin",  limit: 255
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
    t.string   "label",              limit: 255
    t.string   "sound_field",        limit: 255
    t.string   "subtype",            limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "audiocassette_tms", force: :cascade do |t|
    t.string   "cassette_type",          limit: 255
    t.string   "tape_type",              limit: 255
    t.string   "sound_field",            limit: 255
    t.string   "tape_stock_brand",       limit: 255
    t.string   "noise_reduction",        limit: 255
    t.string   "format_duration",        limit: 255
    t.string   "pack_deformation",       limit: 255
    t.boolean  "damaged_tape"
    t.boolean  "damaged_shell"
    t.boolean  "zero_point46875_ips"
    t.boolean  "zero_point9375_ips"
    t.boolean  "one_point875_ips"
    t.boolean  "three_point75_ips"
    t.boolean  "unknown_playback_speed"
    t.boolean  "fungus"
    t.boolean  "soft_binder_syndrome"
    t.boolean  "other_contaminants"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  create_table "batches", force: :cascade do |t|
    t.string   "identifier",      limit: 255
    t.text     "description",     limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "workflow_status", limit: 255
    t.integer  "workflow_index",  limit: 4
    t.string   "destination",     limit: 255
    t.string   "format",          limit: 255
  end

  add_index "batches", ["destination"], name: "index_batches_on_destination", using: :btree
  add_index "batches", ["workflow_status"], name: "index_batches_on_workflow_status", using: :btree

  create_table "betacam_tms", force: :cascade do |t|
    t.string   "pack_deformation",     limit: 255
    t.boolean  "fungus"
    t.boolean  "soft_binder_syndrome"
    t.boolean  "other_contaminants"
    t.string   "cassette_size",        limit: 255
    t.string   "recording_standard",   limit: 255
    t.string   "format_duration",      limit: 255
    t.text     "tape_stock_brand",     limit: 65535
    t.string   "image_format",         limit: 255
    t.string   "format_version",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "betamax_tms", force: :cascade do |t|
    t.string   "format_version",       limit: 255
    t.string   "recording_standard",   limit: 255
    t.string   "tape_stock_brand",     limit: 255
    t.string   "oxide",                limit: 255
    t.string   "format_duration",      limit: 255
    t.string   "image_format",         limit: 255
    t.string   "pack_deformation",     limit: 255
    t.boolean  "damaged_tape"
    t.boolean  "damaged_shell"
    t.boolean  "fungus"
    t.boolean  "other_contaminants"
    t.boolean  "soft_binder_syndrome"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  create_table "billable_physical_objects", force: :cascade do |t|
    t.integer  "mdpi_barcode",  limit: 8
    t.datetime "delivery_date"
  end

  add_index "billable_physical_objects", ["mdpi_barcode"], name: "index_billable_physical_objects_on_mdpi_barcode", unique: true, using: :btree

  create_table "bins", force: :cascade do |t|
    t.integer  "batch_id",                  limit: 4
    t.integer  "mdpi_barcode",              limit: 8
    t.integer  "picklist_specification_id", limit: 8
    t.string   "identifier",                limit: 255,   null: false
    t.text     "description",               limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "spreadsheet_id",            limit: 4
    t.string   "workflow_status",           limit: 255
    t.integer  "workflow_index",            limit: 4
    t.string   "destination",               limit: 255
    t.string   "format",                    limit: 255
    t.string   "physical_location",         limit: 255
    t.integer  "average_duration",          limit: 4
  end

  add_index "bins", ["batch_id"], name: "index_bins_on_batch_id", using: :btree
  add_index "bins", ["destination"], name: "index_bins_on_destination", using: :btree
  add_index "bins", ["picklist_specification_id"], name: "index_bins_on_picklist_specification_id", using: :btree
  add_index "bins", ["spreadsheet_id"], name: "index_bins_on_spreadsheet_id", using: :btree
  add_index "bins", ["workflow_index", "identifier"], name: "index_bins_on_workflow_index_and_identifier", using: :btree
  add_index "bins", ["workflow_status"], name: "index_bins_on_workflow_status", using: :btree

  create_table "boxes", force: :cascade do |t|
    t.integer  "bin_id",            limit: 8
    t.integer  "mdpi_barcode",      limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "spreadsheet_id",    limit: 4
    t.boolean  "full",                            default: false
    t.text     "description",       limit: 65535
    t.string   "format",            limit: 255
    t.string   "physical_location", limit: 255
  end

  add_index "boxes", ["bin_id"], name: "index_boxes_on_bin_id", using: :btree
  add_index "boxes", ["spreadsheet_id"], name: "index_boxes_on_spreadsheet_id", using: :btree

  create_table "cassette_tape_tms", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cdr_tms", force: :cascade do |t|
    t.string   "damage",                 limit: 255
    t.boolean  "fungus"
    t.boolean  "other_contaminants"
    t.boolean  "breakdown_of_materials"
    t.string   "format_duration",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "compact_disc_tms", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "condition_status_templates", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.text     "description",    limit: 65535
    t.string   "object_type",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "blocks_packing",               default: false
  end

  add_index "condition_status_templates", ["object_type", "name"], name: "index_cst_on_object_and_name", using: :btree

  create_table "condition_statuses", force: :cascade do |t|
    t.integer  "condition_status_template_id", limit: 4
    t.integer  "physical_object_id",           limit: 4
    t.text     "notes",                        limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "bin_id",                       limit: 4
    t.string   "user",                         limit: 255
    t.boolean  "active"
  end

  add_index "condition_statuses", ["bin_id", "condition_status_template_id"], name: "index_cs_on_bin_and_cst", using: :btree
  add_index "condition_statuses", ["condition_status_template_id"], name: "index_condition_statuses_on_condition_status_template_id", using: :btree
  add_index "condition_statuses", ["physical_object_id", "condition_status_template_id"], name: "index_cs_on_po_and_cst", using: :btree
  add_index "condition_statuses", ["physical_object_id"], name: "index_condition_statuses_on_physical_object_id", using: :btree

  create_table "dat_tms", force: :cascade do |t|
    t.boolean  "sample_rate_32k"
    t.boolean  "sample_rate_44_1_k"
    t.boolean  "sample_rate_48k"
    t.boolean  "sample_rate_96k"
    t.string   "format_duration",      limit: 255
    t.string   "tape_stock_brand",     limit: 255
    t.boolean  "fungus"
    t.boolean  "soft_binder_syndrome"
    t.boolean  "other_contaminants"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "digital_file_provenances", force: :cascade do |t|
    t.datetime "date_digitized"
    t.text     "comment",               limit: 65535
    t.string   "created_by",            limit: 255
    t.string   "speed_used",            limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "digital_provenance_id", limit: 8
    t.string   "filename",              limit: 255,   null: false
    t.integer  "signal_chain_id",       limit: 8
    t.integer  "tape_fluxivity",        limit: 4
    t.string   "volume_units",          limit: 255
    t.string   "analog_output_voltage", limit: 255
    t.integer  "peak",                  limit: 4
    t.string   "stylus_size",           limit: 255
    t.string   "turnover",              limit: 255
    t.string   "rolloff",               limit: 255
    t.string   "noise_reduction",       limit: 255
  end

  add_index "digital_file_provenances", ["filename"], name: "index_digital_file_provenances_on_filename", unique: true, using: :btree
  add_index "digital_file_provenances", ["signal_chain_id"], name: "index_digital_file_provenances_on_signal_chain_id", using: :btree

  create_table "digital_provenances", force: :cascade do |t|
    t.string   "digitizing_entity",     limit: 255
    t.datetime "date"
    t.text     "comments",              limit: 65535
    t.datetime "cleaning_date"
    t.datetime "baking"
    t.boolean  "repaired"
    t.integer  "physical_object_id",    limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "cleaning_comment",      limit: 65535
    t.text     "xml",                   limit: 4294967295
    t.string   "duration",              limit: 255
    t.text     "batch_processing_flag", limit: 65535
  end

  add_index "digital_provenances", ["physical_object_id"], name: "index_digital_provenances_on_physical_object_id", using: :btree

  create_table "digital_statuses", force: :cascade do |t|
    t.integer  "physical_object_id",           limit: 4
    t.integer  "physical_object_mdpi_barcode", limit: 8
    t.string   "state",                        limit: 255
    t.text     "message",                      limit: 65535
    t.boolean  "accepted"
    t.boolean  "attention"
    t.text     "decided",                      limit: 65535
    t.text     "options",                      limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "decided_manually",                           default: false
  end

  add_index "digital_statuses", ["created_at", "state", "physical_object_id"], name: "quality_control_staging", using: :btree
  add_index "digital_statuses", ["physical_object_id"], name: "index_digital_statuses_on_physical_object_id", using: :btree

  create_table "doFiles", id: false, force: :cascade do |t|
    t.string  "mdpiBarcode", limit: 14,  null: false
    t.integer "partNumber",  limit: 1
    t.boolean "isMaster"
    t.string  "fileUsage",   limit: 255
    t.string  "md5",         limit: 32
    t.integer "size",        limit: 8
    t.float   "duration",    limit: 24
  end

  add_index "doFiles", ["fileUsage"], name: "doFiles_fileUsage", using: :btree
  add_index "doFiles", ["mdpiBarcode", "partNumber"], name: "mdpiBarcode", using: :btree

  create_table "doObjects", primary_key: "mdpiBarcode", force: :cascade do |t|
    t.string   "digitizingEntity", limit: 255
    t.string   "objectType",       limit: 255
    t.datetime "acceptTime"
    t.datetime "bagTime"
    t.integer  "size",             limit: 8
  end

  create_table "doParts", id: false, force: :cascade do |t|
    t.string  "mdpiBarcode", limit: 14, null: false
    t.integer "partNumber",  limit: 1,  null: false
    t.boolean "vendorQC"
  end

  create_table "eight_millimeter_video_tms", force: :cascade do |t|
    t.string   "pack_deformation",     limit: 255
    t.boolean  "fungus"
    t.boolean  "soft_binder_syndrome"
    t.boolean  "other_contaminants"
    t.string   "recording_standard",   limit: 255
    t.string   "format_duration",      limit: 255
    t.string   "tape_stock_brand",     limit: 255
    t.string   "image_format",         limit: 255
    t.string   "format_version",       limit: 255
    t.string   "playback_speed",       limit: 255
    t.string   "binder_system",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "group_keys", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "group_total", limit: 4
    t.string   "avalon_url",  limit: 255
  end

  create_table "half_inch_open_reel_video_tms", force: :cascade do |t|
    t.string   "format_version",       limit: 255
    t.string   "recording_standard",   limit: 255
    t.string   "tape_stock_brand",     limit: 255
    t.string   "format_duration",      limit: 255
    t.string   "image_format",         limit: 255
    t.string   "pack_deformation",     limit: 255
    t.boolean  "damaged_tape"
    t.boolean  "damaged_reel"
    t.boolean  "fungus"
    t.boolean  "soft_binder_syndrome"
    t.boolean  "other_contaminants"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  create_table "machine_formats", force: :cascade do |t|
    t.integer  "machine_id", limit: 4
    t.string   "format",     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "machine_formats", ["machine_id"], name: "index_machine_formats_on_machine_id", using: :btree

  create_table "machines", force: :cascade do |t|
    t.string   "category",     limit: 255
    t.string   "serial",       limit: 255
    t.string   "manufacturer", limit: 255
    t.string   "model",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "memnon_invoice_submissions", force: :cascade do |t|
    t.string   "filename",                      limit: 255
    t.datetime "submission_date"
    t.boolean  "successful_validation"
    t.integer  "validation_completion_percent", limit: 4
    t.boolean  "bad_headers",                                      default: false
    t.text     "other_error",                   limit: 4294967295
    t.text     "problems_by_row",               limit: 4294967295
  end

  create_table "messages", force: :cascade do |t|
    t.text     "content",    limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notes", force: :cascade do |t|
    t.integer  "physical_object_id", limit: 4
    t.text     "body",               limit: 65535
    t.string   "user",               limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "export"
  end

  add_index "notes", ["physical_object_id"], name: "index_notes_on_physical_object_id", using: :btree

  create_table "one_inch_open_reel_video_tms", force: :cascade do |t|
    t.string   "format_version",       limit: 255
    t.string   "recording_standard",   limit: 255
    t.string   "tape_stock_brand",     limit: 255
    t.string   "format_duration",      limit: 255
    t.string   "image_format",         limit: 255
    t.string   "pack_deformation",     limit: 255
    t.boolean  "damaged_tape"
    t.boolean  "damaged_reel"
    t.boolean  "fungus"
    t.boolean  "soft_binder_syndrome"
    t.boolean  "other_contaminants"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.string   "size",                 limit: 255
  end

  create_table "open_reel_tms", force: :cascade do |t|
    t.string   "pack_deformation",               limit: 255
    t.string   "reel_size",                      limit: 255
    t.string   "tape_stock_brand",               limit: 255
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
    t.integer  "calculated_directions_recorded", limit: 4
    t.integer  "directions_recorded",            limit: 4
    t.boolean  "dual_mono"
  end

  create_table "physical_objects", force: :cascade do |t|
    t.integer  "bin_id",                    limit: 4
    t.integer  "box_id",                    limit: 8
    t.integer  "picklist_id",               limit: 8
    t.integer  "container_id",              limit: 8
    t.text     "title",                     limit: 65535
    t.string   "title_control_number",      limit: 255
    t.string   "home_location",             limit: 255
    t.string   "call_number",               limit: 255
    t.string   "iucat_barcode",             limit: 255
    t.string   "format",                    limit: 255
    t.string   "collection_identifier",     limit: 255
    t.integer  "mdpi_barcode",              limit: 8
    t.string   "format_duration",           limit: 255
    t.boolean  "has_ephemera"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "author",                    limit: 255
    t.string   "catalog_key",               limit: 255
    t.string   "collection_name",           limit: 255
    t.string   "generation",                limit: 255
    t.string   "oclc_number",               limit: 255
    t.boolean  "other_copies"
    t.string   "year",                      limit: 255
    t.integer  "unit_id",                   limit: 4
    t.integer  "group_key_id",              limit: 4
    t.integer  "group_position",            limit: 4
    t.boolean  "ephemera_returned"
    t.integer  "spreadsheet_id",            limit: 4
    t.string   "workflow_status",           limit: 255
    t.integer  "workflow_index",            limit: 4
    t.boolean  "staging_requested",                       default: false
    t.boolean  "staged",                                  default: false
    t.datetime "digital_start"
    t.datetime "staging_request_timestamp"
    t.boolean  "audio"
    t.boolean  "video"
    t.boolean  "memnon_qc_completed"
    t.boolean  "billed",                                  default: false
    t.datetime "date_billed"
    t.string   "spread_sheet_filename",     limit: 255
    t.integer  "shipment_id",               limit: 4
  end

  add_index "physical_objects", ["bin_id"], name: "index_physical_objects_on_bin_id", using: :btree
  add_index "physical_objects", ["box_id"], name: "index_physical_objects_on_box_id", using: :btree
  add_index "physical_objects", ["container_id"], name: "index_physical_objects_on_container_id", using: :btree
  add_index "physical_objects", ["group_key_id"], name: "index_physical_objects_on_group_key_id", using: :btree
  add_index "physical_objects", ["picklist_id", "group_key_id", "group_position", "id"], name: "index_physical_objects_on_packing_sort", using: :btree
  add_index "physical_objects", ["shipment_id"], name: "index_physical_objects_on_shipment_id", using: :btree
  add_index "physical_objects", ["spread_sheet_filename"], name: "index_physical_objects_on_spread_sheet_filename", using: :btree
  add_index "physical_objects", ["spreadsheet_id"], name: "index_physical_objects_on_spreadsheet_id", using: :btree
  add_index "physical_objects", ["unit_id"], name: "index_physical_objects_on_unit_id", using: :btree
  add_index "physical_objects", ["workflow_status"], name: "index_physical_objects_on_workflow_status", using: :btree

  create_table "picklist_specifications", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "format",      limit: 255
    t.text     "description", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "picklists", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "description", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "destination", limit: 255
    t.boolean  "complete",                default: false
    t.string   "format",      limit: 255
    t.integer  "shipment_id", limit: 4
  end

  add_index "picklists", ["destination"], name: "index_picklists_on_destination", using: :btree
  add_index "picklists", ["name"], name: "index_picklists_on_name", unique: true, using: :btree
  add_index "picklists", ["shipment_id"], name: "index_picklists_on_shipment_id", using: :btree

  create_table "preservation_problems", force: :cascade do |t|
    t.integer  "open_reel_tm_id",      limit: 4
    t.boolean  "vinegar_odor"
    t.boolean  "fungus"
    t.boolean  "soft_binder_syndrome"
    t.boolean  "other_contaminants"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "preservation_problems", ["open_reel_tm_id"], name: "index_preservation_problems_on_open_reel_tm_id", using: :btree

  create_table "processing_steps", force: :cascade do |t|
    t.integer  "signal_chain_id", limit: 4
    t.integer  "machine_id",      limit: 4
    t.integer  "position",        limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "processing_steps", ["machine_id"], name: "index_processing_steps_on_machine_id", using: :btree
  add_index "processing_steps", ["signal_chain_id"], name: "index_processing_steps_on_signal_chain_id", using: :btree

  create_table "shipments", force: :cascade do |t|
    t.string   "identifier",        limit: 255
    t.string   "description",       limit: 255
    t.string   "physical_location", limit: 255
    t.integer  "unit_id",           limit: 4
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "shipments", ["unit_id"], name: "index_shipments_on_unit_id", using: :btree

  create_table "signal_chain_formats", force: :cascade do |t|
    t.integer  "signal_chain_id", limit: 4
    t.string   "format",          limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "signal_chain_formats", ["signal_chain_id"], name: "index_signal_chain_formats_on_signal_chain_id", using: :btree

  create_table "signal_chains", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "studio",     limit: 255
  end

  create_table "spreadsheets", force: :cascade do |t|
    t.string   "filename",   limit: 255
    t.text     "note",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "spreadsheets", ["filename"], name: "index_spreadsheets_on_filename", unique: true, using: :btree

  create_table "staging_percentages", force: :cascade do |t|
    t.string   "format",         limit: 255,              null: false
    t.integer  "iu_percent",     limit: 4,   default: 10
    t.integer  "memnon_percent", limit: 4,   default: 10
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "technical_metadata", force: :cascade do |t|
    t.integer  "actable_id",                limit: 4
    t.string   "actable_type",              limit: 255
    t.integer  "physical_object_id",        limit: 8
    t.integer  "picklist_specification_id", limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "technical_metadata", ["actable_id", "actable_type"], name: "technical_metadata_as_technical_metadatum_index", using: :btree
  add_index "technical_metadata", ["physical_object_id"], name: "index_technical_metadata_on_physical_object_id", using: :btree
  add_index "technical_metadata", ["picklist_specification_id"], name: "index_technical_metadata_on_picklist_specification_id", using: :btree

  create_table "umatic_video_tms", force: :cascade do |t|
    t.string   "pack_deformation",     limit: 255
    t.boolean  "fungus"
    t.boolean  "soft_binder_syndrome"
    t.boolean  "other_contaminants"
    t.string   "recording_standard",   limit: 255
    t.string   "format_duration",      limit: 255
    t.string   "size",                 limit: 255
    t.string   "tape_stock_brand",     limit: 255
    t.string   "image_format",         limit: 255
    t.string   "format_version",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "units", force: :cascade do |t|
    t.string   "abbreviation", limit: 255
    t.string   "name",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "institution",  limit: 255
    t.string   "campus",       limit: 255
  end

  create_table "users", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.string   "username",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "smart_team_user"
    t.boolean  "smart_team_admin"
    t.boolean  "qc_user"
    t.boolean  "qc_admin"
    t.boolean  "web_admin"
    t.boolean  "engineer"
    t.integer  "unit_id",          limit: 4
    t.boolean  "collection_owner"
  end

  add_index "users", ["unit_id"], name: "index_users_on_unit_id", using: :btree

  create_table "vhs_tms", force: :cascade do |t|
    t.string   "format_version",       limit: 255
    t.string   "recording_standard",   limit: 255
    t.string   "tape_stock_brand",     limit: 255
    t.string   "format_duration",      limit: 255
    t.string   "playback_speed",       limit: 255
    t.string   "size",                 limit: 255
    t.string   "image_format",         limit: 255
    t.string   "pack_deformation",     limit: 255
    t.boolean  "damaged_tape"
    t.boolean  "damaged_shell"
    t.boolean  "fungus"
    t.boolean  "soft_binder_syndrome"
    t.boolean  "other_contaminants"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  create_table "workflow_status_templates", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.text     "description",    limit: 65535
    t.integer  "sequence_index", limit: 4
    t.string   "object_type",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "workflow_status_templates", ["object_type", "name"], name: "index_wst_on_object_and_name", using: :btree
  add_index "workflow_status_templates", ["object_type", "sequence_index"], name: "index_wst_on_object_type_and_sequence_index", using: :btree

  create_table "workflow_statuses", force: :cascade do |t|
    t.integer  "workflow_status_template_id", limit: 4
    t.integer  "physical_object_id",          limit: 4
    t.integer  "batch_id",                    limit: 4
    t.integer  "bin_id",                      limit: 4
    t.text     "notes",                       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "user",                        limit: 255
    t.boolean  "has_ephemera"
    t.boolean  "ephemera_returned"
    t.boolean  "ephemera_okay"
  end

  add_index "workflow_statuses", ["batch_id", "workflow_status_template_id"], name: "index_ws_on_batch_and_wst", using: :btree
  add_index "workflow_statuses", ["bin_id", "workflow_status_template_id"], name: "index_ws_on_bin_and_wst", using: :btree
  add_index "workflow_statuses", ["physical_object_id", "workflow_status_template_id"], name: "index_ws_on_po_and_wst", using: :btree

  create_table "xDigitizingEntity", force: :cascade do |t|
    t.string   "diameter",           limit: 255
    t.string   "speed",              limit: 255
    t.string   "groove_size",        limit: 255
    t.string   "groove_orientation", limit: 255
    t.string   "recording_method",   limit: 255
    t.string   "material",           limit: 255
    t.string   "substrate",          limit: 255
    t.string   "coating",            limit: 255
    t.string   "equalization",       limit: 255
    t.string   "country_of_origin",  limit: 255
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
    t.string   "label",              limit: 255
    t.string   "sound_field",        limit: 255
    t.string   "subtype",            limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "xState", force: :cascade do |t|
    t.string "state", limit: 255
  end

  add_foreign_key "doFiles", "doParts", column: "mdpiBarcode", primary_key: "mdpiBarcode", name: "doFiles_ibfk_1"
  add_foreign_key "doFiles", "doParts", column: "partNumber", primary_key: "partNumber", name: "doFiles_ibfk_1"
  add_foreign_key "doParts", "doObjects", column: "mdpiBarcode", primary_key: "mdpiBarcode", name: "doParts_ibfk_1"
  add_foreign_key "physical_objects", "shipments"
  add_foreign_key "picklists", "shipments"
  add_foreign_key "shipments", "units"
end
