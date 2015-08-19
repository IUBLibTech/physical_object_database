class CreateProcessingSteps < ActiveRecord::Migration
  def change
    create_table :processing_steps do |t|
      t.references :signal_chain, index: true
      t.references :machine, index: true
      t.integer :position

      t.timestamps
    end
  end
end
