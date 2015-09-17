class AddStatsTables < ActiveRecord::Migration
  def up
    if table_exists?(:doFiles)
      puts "Table doFiles already exists."
    else
      puts "Creating table doFiles..."
      create_table "doFiles", id: false, force: true do |t|
        t.string  "mdpiBarcode", limit: 14, null: false
        t.integer "partNumber",  limit: 1
        t.boolean "isMaster"
        t.string  "fileUsage"
        t.string  "md5",         limit: 32
        t.integer "size",        limit: 8
        t.float   "duration"
      end
      add_index "doFiles", ["mdpiBarcode", "partNumber"], name: "mdpiBarcode", using: :btree
    end
    if table_exists?(:doObjects)
      puts "Table doObjects already exists."
    else
      puts "Creating table doObjects..."
      create_table "doObjects", primary_key: "mdpiBarcode", force: true do |t|
        t.string   "digitizingEntity"
        t.string   "objectType"
        t.datetime "acceptTime"
        t.datetime "bagTime"
        t.integer  "size",             limit: 8
      end
    end
    if table_exists?(:doParts)
      puts "Table doParts already exists."
    else
      puts "Creating table doParts..."
      create_table "doParts", id: false, force: true do |t|
        t.string  "mdpiBarcode", limit: 14, null: false
        t.integer "partNumber",  limit: 1,  null: false
        t.boolean "vendorQC"
      end
    end
  end
  def down
    if table_exists?(:doFiles)
      puts "Dropping table doFiles..."
      drop_table :doFiles
    else
      puts "Table doFiles already absent."
    end
    if table_exists?(:doObjects)
      puts "Dropping table doObjects..."
      drop_table :doObjects
    else
      puts "Table doObjects already absent."
    end
    if table_exists?(:doParts)
      puts "Dropping table doParts..."
      drop_table :doParts
    else
      puts "Table doParts already absent."
    end
  end
end
