class AddInstitutionToUnits < ActiveRecord::Migration
  def change
    add_column :units, :institution, :string
    add_column :units, :campus, :string
  end
end
