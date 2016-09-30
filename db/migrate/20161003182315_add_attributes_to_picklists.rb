class AddAttributesToPicklists < ActiveRecord::Migration
  def change
    add_column :picklists, :format, :string
    add_reference :picklists, :shipment, index: true, foreign_key: true
  end
end
