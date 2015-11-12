class RenameTechnicalMetadataActAsColumns < ActiveRecord::Migration
  def up
    rename_column :technical_metadata, :as_technical_metadatum_id, :actable_id
    rename_column :technical_metadata, :as_technical_metadatum_type, :actable_type
  end
  def down
    rename_column :technical_metadata, :actable_id, :as_technical_metadatum_id
    rename_column :technical_metadata, :actable_type, :as_technical_metadatum_type
  end
end
