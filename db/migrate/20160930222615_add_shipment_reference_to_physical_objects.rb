class AddShipmentReferenceToPhysicalObjects < ActiveRecord::Migration
  def change
    add_reference :physical_objects, :shipment, index: true, foreign_key: true
  end
end
