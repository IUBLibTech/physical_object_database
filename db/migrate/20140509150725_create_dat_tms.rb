class CreateDatTms < ActiveRecord::Migration
  def change
    create_table :dat_tms do |t|
    	t.boolean :sample_rate_32k
    	t.boolean :sample_rate_44_1_k
    	t.boolean :sample_rate_48k
    	t.boolean :sample_rate_96k
    	t.string :format_duration
    	t.string :stock_brand
    	t.boolean :fungus
    	t.boolean :soft_binder_syndrome
    	t.boolean :other_contaminants
      t.timestamps
    end
  end
end
