class MemnonDigiProv < ActiveRecord::Migration
  def up
  	# limit sets this to longtext type in MySQL
  	add_column :digital_provenances, :xml, :text, :limit => 4294967295
  end

  def down
  	remove_column :digital_provenances, :xml
  end
end
