class DigitalProvenanceBatchProcessingField < ActiveRecord::Migration
  def change
  	add_column :digital_provenances, :batch_processing_flag, :text
  end
end
