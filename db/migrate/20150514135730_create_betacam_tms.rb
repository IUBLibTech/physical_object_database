class CreateBetacamTms < ActiveRecord::Migration
  def change
    create_table :betacam_tms do |t|
    	t.string :pack_deformation
    	t.boolean :fungus
    	t.boolean :soft_binder_syndrome
    	t.boolean :other_contaminants
    	t.string :cassette_size
    	t.string :recording_standard
    	t.string :format_duration
    	t.text :tape_stock_brand
    	t.string :image_format
    	t.string :format_version
      t.timestamps
    end
  end
end
