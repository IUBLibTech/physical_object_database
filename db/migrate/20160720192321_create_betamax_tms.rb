class CreateBetamaxTms < ActiveRecord::Migration
  def change
    create_table :betamax_tms do |t|
      t.string :format_version
      t.string :recording_standard
      t.string :tape_stock_brand
      t.string :oxide
      t.string :format_duration
      t.string :image_format
      t.string :pack_deformation
      t.boolean :damaged_tape
      t.boolean :damaged_shell
      t.boolean :fungus
      t.boolean :other_contaminants
      t.boolean :soft_binder_syndrome

      t.timestamps null: false
    end
  end
end
