class DigitalProvenanceDuration < ActiveRecord::Migration
  def up
  	add_column :digital_provenances, :duration, :string
  end

  def down
  	remove_column :digital_provenances, :duration, :string
  end
end
