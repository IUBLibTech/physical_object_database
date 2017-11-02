class AddOutOfRoundToCylinderTm < ActiveRecord::Migration
  def change
    add_column :cylinder_tms, :out_of_round, :boolean
  end
end
