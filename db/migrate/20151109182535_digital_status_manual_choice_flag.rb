class DigitalStatusManualChoiceFlag < ActiveRecord::Migration
  def change
  	# this new column denotes whether a decision in a status node was done by a human being or programmatically
  	add_column :digital_statuses, :decided_manually, :boolean, default: false
  end
end
